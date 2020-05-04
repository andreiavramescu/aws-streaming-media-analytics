## How to deploy the CloudFormation template 

#### Deployment using the  UI 
( for command-line check next section)

Prior to deploying the OTT streaming platform, first ensure you are logged in to your AWS account for use in this workshop. To sign in to the AWS Management Console, open https://aws.amazon.com and click on the My Account->AWS Management Console link in the top right corner of the page.

This CloudFormation template deploys all the components except the Databricks Notebooks for an example OTT streaming platform in to your AWS account. 
The deployed environment includes a static website hosted on S3 with sample videos, Kinesis Data Firehose endpoints to accept and process the log data, DynamoDB and AppSync. 
 
1. Open up the CloudFormation console in your AWS account and use the URL received at the end of your build process. 

2. Click the orange Next button located in the bottom right corner of the console to configure the deployment.

3. By default we have set a stack name of mediaqos. There is no need to change this and we refer to this name throughout the guide when identifying resources. If you do decide to change the stack name, please ensure you only use lower-case letters and digits, and keep the name under 12 characters. The stack name is used to name resources throughout the workshop. Keep the name handy as you will need it from time to time to locate resources deployed by the stack.

4. Update the stack name and parameters and click Next.

5. On the next step, Configure stack options, leave all values as they are and click Next to continue.

6. On the Review step

a. Check the three boxes under Capabilities and transforms to acknowledge the template will create IAM resources and leverage transforms.

b. Click the Create stack button located at the bottom of the page to deploy the template.

The stack should take around 5-10 minutes to deploy.
 
## How to build/customize the code 

Setup Instructions
To build with Docker && make

Pre-requisite:
- Install `docker` for your environment as we will use a Docker container to build
- Install AWS CLI
- Install yarn

In Makefile:

  - set `bucket` variable to reflect the S3 bucket name prefix which will be created within a deployment region
  - set `regions` variable to reflect one or more AWS regions you want the code artifacts to be copied for CloudFormation deployment.
  - set `stack_name` for the Stack Name to use in the deployment.
  - set `profile` to the AWS CLI profile which has necessary permissions to deploy and create all the resources required.

Commands to manage creation/deletion of S3 buckets:
- To create buckets across regions: `make creates3`
- To delete buckets across regions: `make deletes3`

Commands to build and deploy the entire project
- `make all`
- `make deploy`

Once the deployment is done you should see the player URL in the Outputs section of the CloudFormation template.
