# AWS CLI Ops Guide

## Prerequisites

Be­fore you get start­ed, please read the [AWS VM Requirements document](07-AWS-VM-Requirements.md).

## Initial AWS CLI Setup

This guide assumes you're using the AWS CLI and that it's already set up and configured to run against your AWS account. If you need assistance setting that up, please see the official AWS docs.

[Official AWS CLI getting started docs](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-quickstart.html)

## Additional notes

### Dev Environment

Please note that these commands are targeted at and tested by Linux users, while the AWS CLI is designed to work with Windows, MacOS, and Linux you may need to adapt some commands to work on your respective OS. Some areas on conflict may be quoting, path separators and environments variables.

### Variable substitution

Please note that when you see sections of the CLI commands that looks like this: `__VARIABLE__`, it is dependent on you to name that yourself.

## Step 1: VPC and Other Networking Components

> ⚠️ **Note:** VPCs, subnets, gateways and other components related to sending traffic to your instance can vary greatly, that is out of scope for this guide. Please refer to your local jurisdictions guidelines to create these resources.

## Step 2: S3 eCR Viewer Data Bucket Creation

To store data for the eCR Viewer, you will need to al­lo­cate an S3 bucket accessible to the EC2 service.

To cre­ate your buckets, you can lever­age either the CLI tool or the Cloud Con­sole. 

[Official AWS S3 User Guide](https://docs.aws.amazon.com/AmazonS3/latest/userguide/Welcome.html)

[Official AWS CLI S3 Create Bucket docs](https://docs.aws.amazon.com/cli/latest/reference/s3api/create-bucket.html)

[Official AWS CLI S3 Put Bucket Policy docs](https://docs.aws.amazon.com/cli/latest/reference/s3api/put-bucket-policy.html)

### Create the Bucket Policy file

```shell
# bucket-policy.json
# your account id __ACCOUNTID__
# your bucket __BUCKETNAME__
# your ssh key __SSHKEYNAME__
```
```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::__ACCOUNTID__:role/__VMROLENAME__"
            },
            "Action": [
                "s3:PutObjectAcl",
                "s3:PutObject",
                "s3:GetObjectAcl",
                "s3:GetObject"
            ],
            "Resource": [
                "arn:aws:s3:::__BUCKETNAME__",
                "arn:aws:s3:::__BUCKETNAME__/*"
            ]
        }
    ]
}
```

#### Create S3 Bucket

> ⚠️ **Note:** If you're not using us-east-1, you'll need to include region and location restraints

```shell
aws s3api create-bucket \
    --bucket __BUCKETNAME__
```

#### Add S3 Bucket Policy

```shell
aws s3api put-bucket-policy \
    --bucket __BUCKETNAME__ \
    --policy file://bucket-policy.json
```

## Step 3: AWS EC2 Role Creation

We'll need to create an EC2 role with a policy that grants it access to the S3 bucket we're going to create.

[Official AWS IAM User Guide](https://docs.aws.amazon.com/IAM/latest/UserGuide/introduction.html)

[Official AWS CLI IAM Create Role docs](https://docs.aws.amazon.com/cli/latest/reference/iam/create-role.html)

[Official AWS CLI IAM Put Role Policy docs](https://docs.aws.amazon.com/cli/latest/reference/iam/put-role-policy.html)

[Official AWS CLI IAM Create Instance Profile docs](https://docs.aws.amazon.com/cli/latest/reference/iam/create-instance-profile.html)

[Official AWS CLI IAM Add Role To Instance Profile docs](https://docs.aws.amazon.com/cli/latest/reference/iam/add-role-to-instance-profile.html)

### Create the Role Policy Files

#### Create Role Policy File

```shell
# role-policy.json
```
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
```

#### Create EC2 Permissions Policy File

> ⚠️ **Note:** It is recommended by us and AWS that you generate your own KMS key for data encryption. You'll need to add arn of your key in the resources list so the eCR Viewer can encrypt and decrypt stored data. Please refer to your local jurisdictions guidelines to create these resources. That process is not yet part of this guide.

```shell
# ec2-permissions-policy.json
# your bucket: __BUCKETNAME__
# "arn:aws:kms:::__KMSKEYID__"
```
```json
{
    "Statement": [
        {
            "Action": [
                "s3:PutObject",
                "s3:PutObjectAcl",
                "s3:DeleteObject",
                "s3:GetObject",
                "s3:GetObjectAcl",
                "s3:ListBucket",
                "kms:GenerateDataKey",
                "kms:Decrypt"
            ],
            "Effect": "Allow",
            "Resource": [
                "arn:aws:s3:::__BUCKETNAME__/*",
                "arn:aws:s3:::__BUCKETNAME__",
            ]
        }
    ],
    "Version": "2012-10-17"
}
```

### Setup your Role

```shell
# your role: __VMROLENAME__
# your policy: __POLICYNAME__
```

#### Create the Role

```shell
aws iam create-role \
    --role-name __VMROLENAME__ \
    --assume-role-policy-document file://role-policy.json \
    --max-session-duration 7200
```

#### Add the Role Policy

```shell
aws iam put-role-policy \
    --role-name __VMROLENAME__ \
    --policy-name __POLICYNAME__ \
    --policy-document file://ec2-permissions-policy.json
```

#### Create the Instance Profile

```shell
aws iam create-instance-profile \
    --instance-profile-name __VMROLENAME__
```

#### Add the Role to the Instance Profile

```shell
aws iam add-role-to-instance-profile \
    --role-name __VMROLENAME__ \
    --instance-profile-name __VMROLENAME__
```

## Step 4: Virtual Machine Creation 

Once you have access to the registered AWS AMI or you created your own, you’re ready to cre­ate a VM in­stance.

[Official AWS EC2 User Guide](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/concepts.html)

[Official AWS CLI EC2 Run Instances docs](https://docs.aws.amazon.com/cli/latest/reference/ec2/run-instances.html)

### Create your EC2 Instance

```shell
aws ec2 run-instances \
--image-id __AMIID__ \
--iam-instance-profile 'Name=__VMROLENAME__' \
--region __REGION__ \
--instance-type m5.large \
--subnet-id __SUBNETID__ \
--security-group-ids __SECURITYGROUPID__ \
--block-device-mappings '[{"DeviceName":"/dev/sda1","Ebs":{"VolumeSize":50}}]' \
--tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=__INSTANCENAME__}]' \
#-- key-name __SSHKEYNAME__ \
# --associate-public-ip-address
```

> ⚠️ **Note:** Configure the instance type, profile, key pair, subnet ID, and security group ID to suit your internal policies and cost requirements. We recommend a minimum boot disk size of 50 GB.

> ⚠️ **Note:** If you're instance doesn't need a public IP address, do not include the `--associate-public-ip-address` option.

## Step 4: Connect to your instance

### With SSH key pair

If you set an SSH key pair on your instance, that key pair will be added to the ubuntu user by default, so use that to log in.

```shell
ssh -i __SSH_KEY_FILE__ ubuntu@__IPADDRESS__
# Switch to the dibbs-user, this is the preferred way to make changes to your instance, or run dibbs scripts
sudo -iu dibbs-user /bin/bash
```

### Without ssh key pair

If you did not set up an SSH key pair on your instance, you can SSH into it using the username and password for `dibbs-user`. If you need the password for your VM version, please reach out to the DIBBS team.

```shell

ssh dibbs-user@__IPADDRESS__
```

Upon logging in, we strong­ly rec­om­mend chang­ing the dibbs-user password.

### Change the dibbs-user password

```shell
sudo passwd dibbs-user
```

En­ter a strong, unique pass­word when prompt­ed and con­firm the change.

## Step 5: eCR Viewer Configuration Wizard

### Setup script

While connect­ed to the VM, run the fol­low­ing command and fol­low the prompts to con­fig­ure the eCR View­er based on your chosen configuration:

> ⚠️ **Note:** Please reference the [eCR Viewer Setup guide](https://cdcgov.github.io/dibbs-ecr-viewer/interfaces/environment.NodeJS.ProcessEnv.html) and the [Environment Variable](https://cdcgov.github.io/dibbs-ecr-viewer/interfaces/environment.NodeJS.ProcessEnv.html) section for more details the following script requests inputs for.

> ⚠️ **Note:** It would be possible to setup your instance on boot using the user-data field, see the [aws example docs](dibbs-ecr-viewer-user-data.md) if you'd like to go that route.

The wiz­ard script will ask you to pro­vide the variables for the eCR Viewer application to run.

```shell
 ./dibbs-ecr-view­er-wiz­ard.sh
```

### Application access

> - eCR Viewer access: __VM.ADDRESS__:3000/ecr-viewer
> - Portainer access: __VM.ADDRESS__:9000

--

- **Version 1.0.0** 

- **We're humans writing docs, if you see an issue or wish something was clearer, [let us know!](https://github.com/CDCgov/dibbs-vm/issues/new/choose)**
