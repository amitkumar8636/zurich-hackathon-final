resource "random_string" "random" {
  length = 6
  lower = true
  special = false
  numeric = false
  upper = false
}

data "aws_availability_zones" "available_zones" {
  state = "available"
}
# VPC Creation
resource "aws_vpc" "hackathon-vpc" {
  cidr_block = "10.1.0.0/16"
}

resource "aws_subnet" "public" {
  count = 2
  cidr_block              = cidrsubnet(aws_vpc.hackathon-vpc.cidr_block, 8, 2 + count.index)
  availability_zone       = data.aws_availability_zones.available_zones.names[count.index]
  vpc_id                  = aws_vpc.hackathon-vpc.id
  map_public_ip_on_launch = true
}

resource "aws_subnet" "private" {
  count = 1
  cidr_block        = cidrsubnet(aws_vpc.hackathon-vpc.cidr_block, 8, count.index)
  availability_zone = data.aws_availability_zones.available_zones.names[count.index]
  vpc_id            = aws_vpc.hackathon-vpc.id
}

resource "aws_internet_gateway" "gateway" {
  vpc_id = aws_vpc.hackathon-vpc.id
}

resource "aws_route" "internet_access" {
  route_table_id         = aws_vpc.hackathon-vpc.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.gateway.id
}

resource "aws_eip" "gateway" {
  count      = 2
  vpc        = true
  depends_on = [aws_internet_gateway.gateway]
}

resource "aws_nat_gateway" "gateway" {
  count         = 1
  subnet_id     = element(aws_subnet.public.*.id, count.index)
  allocation_id = element(aws_eip.gateway.*.id, count.index)
}

resource "aws_route_table" "private" {
  count  = 1
  vpc_id = aws_vpc.hackathon-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = element(aws_nat_gateway.gateway.*.id, count.index)
  }
}

resource "aws_route_table_association" "private" {
  count          = 2
  subnet_id      = element(aws_subnet.private.*.id, count.index)
  route_table_id = element(aws_route_table.private.*.id, count.index)
}

resource "aws_security_group" "lb" {
  name        = "${var.name}-alb-security-group"
  vpc_id      = aws_vpc.hackathon-vpc.id

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb" "hack_lb" {
  name            = "${var.name}-lb"
  subnets         = aws_subnet.public.*.id
  security_groups = [aws_security_group.lb.id]
}

resource "aws_lb_target_group" "hackathon-app" {
  name        = "${var.name}-target-group"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.hackathon-vpc.id
  target_type = "ip"
}

resource "aws_lb_listener" "hackathon-app" {
  load_balancer_arn = aws_lb.hack_lb.id
  port              = "80"
  protocol          = "HTTP"
  default_action {
    target_group_arn = aws_lb_target_group.hackathon-app.id
    type             = "forward"
  }
}

resource "aws_ecs_task_definition" "hackathon-app" {
  family                   = "${var.name}-app-app"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 1024
  memory                   = 2048

  container_definitions = <<DEFINITION
[
  {
    "image": "registry.hub.docker.com/amitkumar8636/hackapp:v1",
    "cpu": 1024,
    "memory": 2048,
    "name": "${var.name}-app",
    "networkMode": "awsvpc",
    "portMappings": [
      {
        "containerPort": ${var.container_port},
        "hostPort": 4566
      }
    ]
  }
]
DEFINITION
}


resource "aws_security_group" "hackathon-app_task" {
  name        = "${var.name}-task-security-group"
  vpc_id      = aws_vpc.hackathon-vpc.id

  ingress {
    protocol        = "tcp"
    from_port       = var.container_port
    to_port         = var.container_port
    security_groups = [aws_security_group.lb.id]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_ecs_cluster" "main" {
  name = "${var.name}-cluster"
}

resource "aws_ecs_service" "hackathon-app" {
  name            = "${var.name}-app-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.hackathon-app.arn
  desired_count   = var.app_count
  launch_type     = "FARGATE"
  

  network_configuration {
    security_groups = [aws_security_group.hackathon-app_task.id]
    subnets         = aws_subnet.private.*.id
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.hackathon-app.id
    container_name   = "${var.name}-app"
    container_port   = var.container_port
  }

  depends_on = [aws_lb_listener.hackathon-app]
}

resource "aws_appautoscaling_target" "dev_to_target" {
  max_capacity = 5
  min_capacity = 1
  resource_id = "service/${aws_ecs_cluster.main.name}/${aws_ecs_service.hackathon-app.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace = "ecs"
}

resource "aws_appautoscaling_policy" "dev_to_memory" {
  name               = "dev-to-memory"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.dev_to_target.resource_id
  scalable_dimension = aws_appautoscaling_target.dev_to_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.dev_to_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }

    target_value       = 80
  }
}

resource "aws_appautoscaling_policy" "dev_to_cpu" {
  name = "dev-to-cpu"
  policy_type = "TargetTrackingScaling"
  resource_id = aws_appautoscaling_target.dev_to_target.resource_id
  scalable_dimension = aws_appautoscaling_target.dev_to_target.scalable_dimension
  service_namespace = aws_appautoscaling_target.dev_to_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }

    target_value = 60
  }
}
