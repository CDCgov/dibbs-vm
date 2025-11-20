# AWS Guide to Setting Up a DIBBs Virtual Machine Instance

## Prerequisites

Be­fore you get start­ed, please read the [AWS VM Requirements document](07-AWS-VM-Requirements.md).

## Initial AWS CLI Setup

This guide assumes you're using the AWS CLI and that it's already set up and configured to run against your desired AWS account. If you need assistance setting that up, please see the official AWS docs.

[Official AWS CLI getting started docs](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-quickstart.html)

## Additional notes

### Dev Environment

Please note that these commands are targeted at and tested by Linux users, while the AWS CLI is designed to work with Windows, MacOS, and Linux you may need to adapt some commands to work on your respective OS. Some areas on conflict may be quoting, path separators and environments variables.

### Variable substitution

Please note that when you see sections of the CLI commands that looks like this: `__VARIABLE__`, it is dependent on you to name that yourself.

## AWS EC2 Role Creation

We'll need to create an EC2 role with a policy that grants it access to the S3 bucket we're going to create.

### Create the Role Policy Files

```shell
# create a file
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

```shell
# create a file
# ec2-permissions-policy.json
# your bucket: __BUCKETNAME__
```
```json
{
    "Statement": [
        {
            "Action": [
                "s3:Put*",
                "s3:Get*"
            ],
            "Effect": "Allow",
            "Resource": [
                "arn:aws:s3:::__BUCKETNAME__/*",
                "arn:aws:s3:::__BUCKETNAME__"
            ]
        }
    ],
    "Version": "2012-10-17"
}
```

### Setup your role

```shell
# create the role
# your role: __VMROLENAME__
# your policy: __POLICYNAME__
# your profile: __VMPROFILENAME__
aws iam create-role \
    --role-name __VMROLENAME__ \
    --assume-role-policy-document file://role-policy.json \
    --max-session-duration 7200

# add the role policy
aws iam put-role-policy \
    --role-name __VMROLENAME__ \
    --policy-name __POLICYNAME__ \
    --policy-document file://ec2-permissions-policy.json

# Create the instance profile
aws iam create-instance-profile --instance-profile-name __VMROLENAME__

# Add the role to the instance profile
aws iam add-role-to-instance-profile --role-name __VMROLENAME__ --instance-profile-name __VMROLENAME__
```

## S3 eCR Viewer Data Bucket Creation

To store data for the eCR Viewer, you will need to al­lo­cate an S3 bucket accessible to the EC2 service.

To cre­ate your buckets, you can lever­age ei­ther the CLI tool or the Cloud Con­sole. 

[Official AWS Create Bucket Overview docs](https://docs.aws.amazon.com/AmazonS3/latest/userguide/create-bucket-overview.html)

[Official AWS CLI S3 Create Bucket docs](https://docs.aws.amazon.com/cli/latest/reference/s3api/create-bucket.html)

[Official AWS CLI S3 Put Bucket Policy docs](https://docs.aws.amazon.com/cli/latest/reference/s3api/put-bucket-policy.html)

### Create the Bucket Policy file

```shell
# create a file
# bucket-policy.json
# your account id __ACCOUNT_ID__
# your bucket __BUCKETNAME__
```
```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::__ACCOUNT_ID__:role/__VMROLENAME__"
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

### Create the Bucket and Policy

```shell
# replace __NAME__ and __REGION__ with your own information
# create your bucket
# if you're using not using us-east-1, you'll need to specify your region and location contraints
aws s3api create-bucket \
    --bucket __BUCKETNAME__

# add a policy
aws s3api put-bucket-policy \
    --bucket __BUCKETNAME__ \
    --policy file://bucket-policy.json
```

## Virtual Machine Creation 

Once you have access to the registered AWS AMI(or you created your own based on this repository), you’re ready to cre­ate a VM in­stance. 

### Create your EC2 Instance

```shell
aws ec2 run-instances \
--image-id __AMIID__ \
--profile __VMROLENAME__ \
--region __REGION__ \
--instance-type m5.large \
--subnet-id __SUBNET_ID__ \
--security-group-ids __SECURITY_GROUP_ID__ \
--block-device-mappings '[{"DeviceName":"/dev/sda1","Ebs":{"VolumeSize":50}}]' \
--tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=__INSTANCENAME__}]'
# --associate-public-ip-address
```

**Note:** Configure the instance type, profile, key pair, subnet ID, and security group ID to suit your internal policies and cost requirements. We recommend a minimum boot disk size of 50 GB to start.

**Note:** If you're instance doesn't need a public IP address, do not include the `--associate-public-ip-address` option.

## Connect to your instance

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

Upon log­ging in, we strong­ly rec­om­mend chang­ing the dibbs-user password.

### Change the dibbs-user password

```shell
sudo passwd dibbs-user
```

En­ter a strong, unique pass­word when prompt­ed and con­firm the change.

## eCR Viewer Setup  

While con­nect­ed to the VM, run the fol­low­ing com­mand and fol­low the prompts to con­fig­ure the eCR View­er based on your chosed configuration:

```shell  
 ./dibbs-ecr-view­er-wiz­ard.sh
```  

The wiz­ard script will ask you to pro­vide the vari­ables for the eCR Viewer application to run.

**Note:** It would be possible to setup your instance on boot using the user-data field, see the [aws example docs](examples/aws/dibbs-ecr-viewer.md) if you'd like to do so.

--

- **Version 1.0.0** 

- **We're humans writing docs, if you see an issue or wish something was clearer, [let us know!](https://github.com/CDCgov/dibbs-vm/issues/new/choose)**
