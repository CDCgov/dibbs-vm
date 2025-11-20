# AWS Guide to Setting Up a DIBBs Virtual Machine Instance

*Version 1.0.0*

Thank you for choosing to be­come a part­ner for the eCR View­er! This doc­u­ment is de­signed to help you pre­pare for your first AWS de­ploy­ment of the eCR View­er stack.

If you have any ques­tions as you move through the process, please feel free to reach out to the DIBBs team at any time. We’re hap­py to help! 

You can lever­age ei­ther the Amazon Web Services Dashboard (GUI) or the AWS CLI tool to per­form most of the operations in this guide. We will pro­vide spe­cif­ic CLI com­mands along with links to official AWS docs where ap­pro­pri­ate.

## Prerequisites

Be­fore you get start­ed, there are a few requirements you need to be sure you have ready. 

- Determine the eCR Viewer configuration your organization plans to use.

[Click here to view information about the available configurations.](https://cdcgov.github.io/dibbs-ecr-viewer/documents/Setup_Guide.html#general-background)

Please reach out if you have any questions about these options or need help deciding.

- You’ll need to have an account, per­mis­sions, and nec­es­sary func­tion­al­i­ty set up in AWS. 
- You’ll need to have access to the registered DIBBS VM AMI in your AWS account. 
- You’ll need to have an S3 bucket set up in AWS to store your eCR data, with the prop­er net­work­ing and ac­cess pro­vi­sions for EC2.
- You’ll need to have a data­base set up (on-premise or cloud-based, Mi­crosoft SQL or  Post­gre­SQL) and ac­ces­si­ble via the AWS net­work. 
- You’ll need to have an Entra, or Key­cloak client created or NBS authentication for the eCR View­er ap­pli­ca­tion.
- You’ll need to have IAM permissions to make adjustments within your AWS en­vi­ron­ment.

## Initial AWS CLI Setup

This guide assumes you're AWS CLI is already setup and configured, if you need assistance on setting that up, please see the official AWS docs.

[Official AWS CLI getting started docs](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-quickstart.html)

## AWS EC2 Role Creation

We'll need to create a role that ec2 can assume with a policy that allows it to access the S3 bucket we're going to create.

### Using Command Line:

```
# role-policy.json
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

```
# ec2-permissions-policy.json
{
    "Statement": [
        {
            "Action": [
                "s3:Put*",
                "s3:Get*"
            ],
            "Effect": "Allow",
            "Resource": [
                "arn:aws:s3:::<BUCKETNAME>/*",
                "arn:aws:s3:::<BUCKETNAME>"
            ]
        }
    ],
    "Version": "2012-10-17"
}
```

```bash
# Create the role
aws iam create-role \
    --role-name <VMROLENAME> \
    --assume-role-policy-document file://role-policy.json \
    --max-session-duration 7200

# Add the role policy
aws iam put-role-policy \
    --role-name <VMROLENAME> \
    --policy-name <POLICYNAME> \
    --policy-document file://ec2-permissions-policy.json

# Create the instance profile
aws iam create-instance-profile --instance-profile-name YourEC2RoleName-Profile

# Add the role to the instance profile
aws iam add-role-to-instance-profile --role-name YourEC2RoleName --instance-profile-name YourEC2RoleName-Profile

```

### Us­ing AWS Dashboard: 




## S3 eCR Viewer Data Bucket Creation

To store the data for the eCR Viewer, you will need to al­lo­cate an S3 bucket that is accessable to the EC2 service.

To cre­ate your buckets, you can lever­age ei­ther the CLI tool or the Cloud Con­sole. 

[Official AWS Create Bucket Overview docs](https://docs.aws.amazon.com/AmazonS3/latest/userguide/create-bucket-overview.html)

[Official AWS CLI S3 Create Bucket docs](https://docs.aws.amazon.com/cli/latest/reference/s3api/create-bucket.html)

[Official AWS CLI S3 Put Bucket Policy docs](https://docs.aws.amazon.com/cli/latest/reference/s3api/put-bucket-policy.html)

### Us­ing Com­mand Line:

```
# bucket-policy.json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::<ACCOUNT_ID>:role/<VMROLENAME>"
            },
            "Action": [
                "s3:PutObjectAcl",
                "s3:PutObject",
                "s3:GetObjectAcl",
                "s3:GetObject"
            ],
            "Resource": [
                "arn:aws:s3:::<BUCKETNAME>",
                "arn:aws:s3:::<BUCKETNAME>/*"
            ]
        }
    ]
}
```

```bash
# Replace <NAME> and <REGION> with your own information
# Create your bucket
aws s3api create-bucket \
    --bucket <BUCKETNAME> \
    --region <REGION> \
    --create-bucket-configuration LocationConstraint=<REGION>

# Create a policy.json file with your policy, see docs linked above for more information
# A policy that allows getObject and putObject should be sufficient
# Add a policy
aws s3api put-bucket-policy \
    --bucket <BUCKETNAME> \
    --policy file://bucket-policy.json
```

### Us­ing AWS Dashboard: 

1. Nav­i­gate to S3 > Buckets 
2. Click Cre­ate Bucket and fill in the de­tails, include the policy you'd like.

CAU­TION: The bucket you set up for your eCR data should be prop­er­ly scoped to ensure maximum privacy. Be careful not to set the bucket public, and please en­sure you are fol­low­ing your lo­cal ju­ris­dic­tion’s poli­cies and pro­ce­dures for the pro­tec­tion of PHI and PII.

Note the end­point in­for­ma­tion for the eCR bucket. You will need to pro­vide this to the virtual machine during setup. 

## Database Setup (Only required for NON_INTEGRATED and DUAL configurations)

The database setup is very juristiction dependent so we're only going to forego specific setup instructions. You should follow all of your local juristictions policies and procedures for database setup. 

The eCR View­er can be con­fig­ured to in­ter­face with an in­stance of Post­gre­SQL or Microsoft SQL Server for stor­age and re­trieval of data. This data­base in­stance can be ei­ther cloud-based or lo­cat­ed on-premises. Your Post­gre­SQL in­stance needs to meet the fol­low­ing re­quire­ments:

- Must be reach­able over the net­work, ei­ther with­in your AWS account, via net­work peering to an­oth­er AWS account, or via a net­work route to your on premise in­stance. 
- Must have prop­er backups/snap­shots con­fig­ured, to al­low for roll­backs in case of a failed mi­gra­tion or oth­er data in­con­sis­ten­cy. 
- Must fol­low prop­er re­ten­tion poli­cies and au­dit log­ging as re­quired by your ju­ris­diction’s ap­plic­a­ble laws, statutes, and reg­u­la­tions. 

We strong­ly rec­om­mend cre­at­ing a ded­i­cat­ed data­base user for use by the eCR Viewer application. Once you have cre­at­ed this user, en­sure that their per­mis­sions are prop­er­ly scoped to the least priv­i­lege in ac­cor­dance with your in­ter­nal poli­cies. The user will need to be able to create and modify tables and schemas on the database you use.

Then, take note of the user­name and pass­word for this user. You will need these val­ues for the vir­tu­al ma­chine’s set­up process.

## Entra or Keycloak Setup (Only required for NON_INTEGRATED and DUAL configurations)

To in­te­grate the eCR View­er with your ex­ist­ing Entra or Key­cloak in­stance, you will need to cre­ate a new reg­is­tra­tion for the View­er ap­pli­ca­tion. You don’t have to con­fig­ure groups and roles at this time; user per­mis­sions are cur­rent­ly man­aged with­in the eCR View­er in­ter­face. 

Take note of the client ID, client se­cret, and is­suer in­for­ma­tion. You will need these val­ues  when you per­form ini­tial con­fig­u­ra­tion of the VM in­stance.

## Permissioning

Your vir­tu­al ma­chine instance will need permissions and network access to the S3 Data Bucket, the Database (if applicable), and Entra or Keycloak (if applicable) to function correctly.

## Virtual Machine Creation 

Once you have access to the registered AWS AMI(or you created your own based on this repository), you’re ready to cre­ate a VM in­stance. 

### Us­ing Com­mand Line:

```bash
aws ec2 run-instances \
--image-id <AMI-ID> \
--instance-type m5.large \
--key-name <SSH_KEY_NAME> \
--subnet-id <SUBNET_ID> \
--security-group-ids <SECURITY_GROUP_ID> \
--block-device-mappings '[{"DeviceName":"/dev/sda1","Ebs":{"VolumeSize":50}}]'
```

Note: Configure the instance type, key pair, subnet ID, and security group ID to suit your internal policies and cost requirements. We recommend a minimum boot disk size of 50 GB to start.

### Using AWS Dashboard:

1. Navigate to EC2 Dashboard > Instances.
1. Click on Launch Instance.
1. Name your machine.
1. Select the ubuntu-2404-dibbs-ecr-viewer Amazon Machine Image (AMI) under “My AMIs”.
1. Configure the instance details:
    1. Number of instances: 1
    1. Network settings:
        1. Select your VPC 
        1. Subnet: Choose a subnet within your chosen VPC
        1. Auto-assign Public IP: Enable if you need public access to the instance
        1. Select your security group; you’ll need to expose port 22 when configuring the eCR Viewer running on the instance.
1. Add storage:
1. Click Add New Volume, then set its size to at least 50 GB.
1. Add tags (optional)
1. You can set User Data within the advanced options if you want to automate setup or other tasks on boot.
1. Select an existing key pair or create a new one to connect to your instance via SSH.
1. Review and launch the instance.

This will create an EC2 instance using your specified image and configurations. Ensure your AWS account has the necessary permissions to perform these actions.

<TODO>

## SSH Access and Password Setup To con­nect to your VM in­stance, use the fol­low­ing GCP com­mand: 

```shell
gcloud com­pute ssh user­name@your-in­stance-name --zone=your-zone -- project=your-project-id
```

Upon log­ging in, we strong­ly rec­om­mend chang­ing the pass­word for your pro­vid­ed user us­ing Com­mand Line.

sudo pass­wd <user­name> # Re­place <user­name> with the user's name pro­vid ed to you by the DIBBs team  

En­ter a strong, unique pass­word when prompt­ed and con­firm the change.

<TODO>
## eCR Viewer Setup  

While con­nect­ed to the VM, run the fol­low­ing com­mand and fol­low the prompts to con­fig­ure the eCR View­er based on your chosed configuration:

```bash  
 ./dibbs-ecr-view­er-wiz­ard.sh  
```  

The wiz­ard script will ask you to pro­vide the vari­ables for the eCR Viewer application to run:

●  CON­FIG_­NAME should be set to GCP_PG_­D­UAL. 
●  GCP_­CRE­DEN­TIALS and GCP_PRO­DUC­T_ID should match your GCP con­fig­u­ra­tion. 
●  NB­S_API_PUB­_KEY and NB­S_PUB­_KEY should match the full pub­lic key val­ues need ed to con­nect to your Epi­Trax in­stance. You can gen­er­ate a pub­lic/pri­vate key­pair us ing any ser­vice or util­i­ty of your choos­ing.
7 
●  DATA­BASE_URL should be set to a post­gres-com­pat­i­ble con­nec­tion string URI, of the  for­mat post­gres[ql]://[user­name[:pass­word]@][host[:port],]/data base[?pa­ra­me­ter_­list]. Make sure to prop­er­ly per­cent-en­code your pa­ra­me ter val­ues! 
●  AU­TH_PROVIDER should be set to key­cloak 
●  AU­TH_­CLIEN­T_ID and AU­TH_­CLIEN­T_SE­CRET should match what you con­fig­ured for  the new eCR View­er ap­pli­ca­tion reg­is­tra­tion ear­li­er in this guide. 
●  AU­TH_IS­SUER should cor­re­spond to the set­tings you’ve con­fig­ured in your Key­cloak  in­stance. 
Af­ter you’ve run the wiz­ard, its con­fig­u­ra­tion will be stored at ~/dibbs-vm/dibbs-ecr view­er/dibbs-ecr-view­er.env. If you ever need to make changes, you can ei­ther re-run  the wiz­ard script, or sim­ply mod­i­fy this file di­rect­ly. 

## Portainer Setup  

We’ve in­clud­ed a copy of Por­tain­er in the eCR View­er stack. This ap­pli­ca­tion will al­low you to  man­age Dock­er us­ing a web-based GUI, where you can con­fig­ure re­sources, view logs, and  per­form oth­er ad­min­is­tra­tive ac­tions.

To get start­ed, vis­it http://<VM_AD­DRESS>:9000 in your brows­er of choice. It is recommended that you restrict access to Portainer using security groups, allowing only the administrator IP access when needed. Click here for official docs re­gard­ing Por­tain­er’s func­tions.

## Additional Security Steps  

We strong­ly rec­om­mend lock­ing down your VM in­stance in ac­cor­dance with your ju­ris­dic­tion’s  ap­plic­a­ble poli­cies, reg­u­la­tions, and statutes. 

Steps to con­sid­er in­clude:

- Ac­ti­vate a fire­wall with­in AWS.
- Con­fig­ure IP ac­cess re­stric­tions. 
- Re­strict SSH ac­cess. 
- Route traf­fic to the VM through a load bal­ancer or gate­way. 

## Required Ports  

If you choose to im­ple­ment a fire­wall, please note that the fol­low­ing are in use by the  eCR View­er con­tain­er stack: 

- eCR View­er: 
  - Port: 3000
  - This is the ingress for the applications, potentially placed behind a load balancer.
- Por­tai­ner ma­na­ge­ment console:
  - Port: 9000
  - This is an admin console that should not be generally available, ensure it's secure and only made available if or when it's needed.
