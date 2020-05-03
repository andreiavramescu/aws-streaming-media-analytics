# QoS Solution based on the AWS Streaming Media Analytics

The aim of this solution is to provide the core for any streaming video platform that wants to improve their QoS system. 

- [QoS Solution]
  - [Solution Architecture](#Architecture-Overview)
  - [Databricks QoS Notebooks](#QoS-Noebooks)
  - [How to deploy the platform](#How-to-deploy-the-platform)
  - [License Summary](#License-Summary)

## Architecture Overview

The Architecture includes standard AWS components for the video streaming side of an OTT platform and Databricks as a Unified Data Analytics Platform for both the real time insights and the advanced analytics (machine learning) capabilities.

![alt text](images/arch.png "Architecture Overview")

##QoS Notebooks

The [Notebooks](notebooks/QOSNOTEBOOKS.md) provided are showcasing an end-to-end project using [Delta](https://delta.io/) and a Delta Architecture pattern :
- the data ingestion including a `make your data available to everyone pipeline` with real-time data enrichment and anonymisation    
- real-time notifications based on a complex rules engine or machine learning based scoring 
- real-time aggregations to update the web application
- quick shareable Dashboard built directly on top of the datasets stored in your Delta Lake

## How to deploy the platform

As a minimum level of requirements in order to deploy the platform you must have access to an AWS account with a Databricks workspace and Docker installed on your local environment to build the code.

Deployment:

1. Clone the project and configure the Makefile and the CloudFormation template
    - set `bucket` variable to reflect the S3 bucket name prefix which will be created within a deployment region
    - set `regions` variable to reflect one or more AWS regions you want the code artifacts to be copied for CloudFormation deployment.
    - set `stack_name` for the Stack Name to use in the deployment.
    - set `profile` to the AWS CLI profile which has necessary permissions to deploy and create all the resources required. 
              
2. Build and upload the code in the source bucket in S3: `make all`. Once the build is completed,you can use the URL for your CloudFormation script in the next step. 
      
3. [Deploy the CloudFormation](deployment/CLOUDFORMATION.md) script either using the make deploy command or using the UI. 
      
4. Configure the [IAM passthrough for Databricks Cluster](https://docs.databricks.com/security/credential-passthrough/iam-passthrough.html#launch-cluster)
      
5. Import the Databricks archive with [QoS Notebooks](notebooks/QOSNOTEBOOKS.md) in your environment. 
      
6. You are ready to go! Enjoy the QoS Solution!  

Any changes to the code of the solution will require to run the same process ( build, upload code, deploy the new app ).

## License Summary

This sample code is made available under the MIT-0 license. See the LICENSE file.

