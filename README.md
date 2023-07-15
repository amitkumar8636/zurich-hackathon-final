
# Zurich Cloud Hackathon
### Final phase-cloud-challenge

This part of the block-1 is covering the below requirement:



## Block 1

```javascript
BLOCK 1 is about creating a specific IaC project infrastructure as well as implement a local CI/CD on a git software. It is divided into two parts:

Part 1: Create and develop an infrastucture using an IaC, only Terraform or Cloud Formation. The infrastructure should create 2 EC2 instances in the same virtual cloud and subnet. Both instances would host services in the future. These services would be running in ports: 443 using TCP, 1337 using TCP and 3035 using TCP and UDP. Each instance should be accessed via SecureShell on the default port using a different key for each instance.

Decisions such as image, security group and scalability of the infrastructure, as well as the code, will be evaluated.
```


## Installation

```bash
Please install Terraform version: 1.5.2 as it is tested on this version:
For detailed installation refer the Pre-stage code: https://github.com/amitkumar8636/zurich-Cloud-hackathon-teamRain 
```


    
## FAQ

#### Is the code limited to 2 ec2 instance only?

No the code is using *total_key_pairs* variable in order to decide the no of instance. As in the problem statement it was clearly mention that every ec2 needs a different key pair. so in case you change to 8 then 8 no of key pair will be created and the same key pair can be used to authenticate with ssh.

#### How are you selecting the image?
We are fetching the available images based on the filter provided in the variable list. In case of you need to fetch only Secuirity hardened AMI, Feel free to update the filter. 

#### How do i find which key to use in which ec2 instance?

You can check the tag of each ec2 instance, there will be *key* tag which has the same value which has the generated key name.

#### How did you rules in sg?
Though as of now, it is duplicated however this still can be improved using dynamic blocks, Considering time crunch not updating to the code to using dynamic blocks.

#### Is the code modular?
Yes, Almost code is modular. However there are some points of improvements still exist.


#### Did you completed Part2?
Well, in Short No. As i didn't get a time to look into the second part as i'm more into AWS and Terrraform so i started the developing the infrastructure first. Also, for configuration of the CICD is nothing difficult if you have proper resources and access.

## Block 2

```javascript
The problem is being able to efficiently scale a WebApp for uploading images into an S3 AWS bucket.
```


## FAQ

#### What service you choose the deploying the containerzed application

We choose to go with ECS service as in FARGET mode. As it is the best alternative to Kubernates and can scale based on the request(Precisely based on Memory and CPU consumption.). We also have put a threshold of memory 80% and CPU 60% to add more no of task to serve the request while on the initial go, we are going with minimum 2 containers. It works the same way like Kubernates HPA(Horizontal Pod Scaler) works.

#### What if the sudden raise of traffic, Will this able to handle the request in that case?

Well, Defenetly Yes, This one is tried and tested and we are using in our current organasation as we are moving out from Kubernates(EKS). We haven't seen any issue.

#### Is there any another way we can build this scalable infrastructure?

Yes, There are couple of ways we can design this infrastructure, we can go with Elastic Beanstalk service which actully abstract all the settings like ASG, LB rather than going with tradition approach.

We can also go with Lambda with reserved concurrency if our code is static and doesn't need a startup time like Java Spring boot and connecting to RDS services. For the current case, I beleive the Lambda is perfect fit.


#### How does it optimizez cost?
When you are using ECS in Farget mode, this is little expensive considering regular mode, However the cost is justified if the service is critical and customer facing. I have selected FARGET considering that its an critical application and we cant afford the downtime of the application.


#### Did you used localstack to deploy the services?
I have executed this terraform code on actual aws environment. Also i need to check weather the same resources are available on localstack or not accordingly we can modify the provider configuration to use localstack.

#### Is your application is running?

I have build the docker images and docker file doesn't container the container port. Im not sure what is the container port. The wrong container port causing the task to restart in loop like happens in kubernates. In this case(I build the image from the docker file provided which is absolultly wrong)

We got the requirement specific error that *ERROR: No matching distribution found for render_template* while building the image of app.py python codes, Im assuming that the code has been tested earlier and the only part need to to is containerize the application.

meanwhile You can update the correct image to get it run.