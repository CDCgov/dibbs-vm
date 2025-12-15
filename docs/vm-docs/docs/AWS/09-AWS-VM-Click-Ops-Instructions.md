# AWS Click Ops Guide

## Prerequisites

Be­fore you get start­ed, please read the [AWS VM Requirements document](07-AWS-VM-Requirements.md).

Consider using the [AWS CLI Ops Guide](08-AWS-VM-CLI-Ops-Instructions.md)!

### Variable substitution

Please note that when you see sections of the CLI commands that looks like this: `__VARIABLE__`, it is dependent on you to name that yourself.

## Step 1: VPC and Other Networking Components

> ⚠️ **Note:** VPCs, subnets, gateways and other components related to sending traffic to your instance can vary greatly, that is out of scope for this guide. Please refer to your local jurisdictions guidelines to create these resources.

## Step 2: AWS EC2 Role Creation

We'll need to create an EC2 role with a policy that grants it access to the S3 bucket we're going to create.

> ⚠️ **Note:** It is recommended by us and AWS that you generate your own KMS key for data encryption. You'll need to add arn of your key in the resources list so the eCR Viewer can encrypt and decrypt stored data. Please refer to your local jurisdictions guidelines to create these resources. That process is not yet part of this guide.


### EC2 Permissions Policy

```shell
# your bucket: __BUCKETNAME__
# "arn:aws:kms:::*",
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

### Role Policy

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

#### Click Ops Instructions

1. Go to `IAM` in `AWS` management console
2. Select `Policies` in the left side blade
3. Select `Create policy` button on the right top side
4. Select `JSON` toggle to switch to the json editor
5. Paste in the [EC2 Permissions Policy](#ec2-permissions-policy), be sure to update variables
6. Select `Next` button on the right bottom side
7. Name your policy
8. Select `Create policy` button on the right bottom side
9.  Select `Roles` in the left side blade
10. Select `Create role` button on the right top side
11. Select `Custom trust policy` from the `Trusted entity type` list
12. Paste in the [Role Policy](#role-policy)
13. Select `Next` button on the right button side
14. Search for your previously created EC2 Permissions Policy
15. Select the checkbox for your policy
16. Select `Next` button on the right bottom side
17. Name your role
18. Select `Create role` button on the right bottom side

## Step 3: S3 eCR Viewer Data Bucket Creation

To store the data for the eCR Viewer, you will need to al­lo­cate an S3 bucket that is accessible to the EC2 service.

> ⚠️ **Note:** The bucket you set up for your eCR data should be prop­er­ly scoped to ensure maximum privacy. Be careful not to set the bucket public, and please en­sure you are fol­low­ing your lo­cal ju­ris­diction’s policies and procedures for the protection of PHI and PII.

> ⚠️ **Note:** You will need to pro­vide the name of this bucket to the virtual machine during setup. 

### Bucket Policy:

```
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

#### Click Ops Instructions

1. Go to `S3` in `AWS` management console
2. Click `Create bucket` button
3. Name your bucket (be sure this matches your role policies)
4. Select an `Object Ownership` option
5. Select `Block all public access`
6. Select a versioning option
7. Add tags
8. Select `Default encryption` options
9. Select `Create bucket` button on the right bottom side
10. Select the bucket you just created
11. Select `Permissions` tab in the top row
12. Select `Edit` in the `Bucket Policy` section
13. Paste in the [Bucket Policy](#bucket-policy), be sure to update variables

## Step 4: Virtual Machine Creation 

Once you have access to the registered AWS AMI or you created your own, you’re ready to cre­ate a VM in­stance. 


> ⚠️ **Note:** Configure the instance type, key pair, subnet ID, and security group ID to suit your internal policies and cost requirements. We recommend a minimum boot disk size of 50 GB to start.

### Using AWS Dashboard:

1. Go to `EC2` in `AWS` management console
2. Select `Launch Instance`
3. Name your machine
4. Select `My AMIs` tab in the `Application and OS Images (Amazon Machine Image)` section
5. Select the latest version of the `*dibbs-ecr-viewer*`
6. Select an `Instance type`
7. Select a `Key pair`, or select `Proceed without a key pair`
8. Configure your `Network Settings`
   1. Select a `Network`
   2. Select a `Subnet`
   3. Select an option for `Auto-assign Public IP`
   4. Select `Firewall` options
9. Configure your storage(+50GB recommended)
10. Configure the instance details:
    1. Number of instances: 1
    2. Network settings:
        1. Select your VPC 
        2. Subnet: Choose a subnet within your chosen VPC
        3. Auto-assign Public IP: Enable if you need public access to the instance
        4. Select your security group; you’ll need to expose port 22 when configuring the eCR Viewer running on the instance.
11. Configure any advanced settings you desire
12. Select `Launch instance` button on the right side blade

This will create an EC2 instance using your specified image and configurations. Ensure your AWS account has the necessary permissions to perform these actions.

## Step 5: Connect to your instance

It could be possible to connect with your instance via SSH, but how this is done is often dependent on your network environment. Going deep into this section is out of the scope of this guide, but below should be enough information to get your connected.

> ⚠️ **Note:** We strongly encourage anybody launching this VM to change the default password they received from the DIBBS DevOps team. Instructions are provided below. Please follow your jurisdictions guidelines.

### With SSH key pair

If you set an SSH key pair on your instance(AWS recommends that you do this), that key pair will be added to the ubuntu user by default, so use that to log in.

```shell
ssh -i __SSH_KEY_FILE__ ubuntu@__IPADDRESS__
# Switch to the dibbs-user, this is the preferred way to make changes to your instance, or run dibbs scripts
sudo -iu dibbs-user /bin/bash
```

### Without ssh key pair

If you did not set up an SSH key pair on your instance, you can SSH into it using the username and password for `dibbs-user`. If you need the password for your VM version, please reach out to the DIBBS DevOps team.

```shell

ssh dibbs-user@__IPADDRESS__
```

Upon log­ging in, we strong­ly rec­om­mend chang­ing the dibbs-user password.

### Change the dibbs-user password

```shell
sudo passwd dibbs-user
```

En­ter a strong, unique pass­word when prompt­ed and con­firm the change.

## Step 6: eCR Viewer Configuration

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
