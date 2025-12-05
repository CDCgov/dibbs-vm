# AWS VM Requirements

Thank you for choosing to be­come a part­ner for the eCR View­er! This document is de­signed to help you pre­pare for your first AWS deployment of the eCR View­er stack.

If you have any questions as you move through the process, please feel free to reach out to the DIBBs team at any time. We’re hap­py to help! 

You can lever­age either the Amazon Web Services Dashboard (GUI) or the AWS CLI tool to per­form most of the operations in these guides.

## Prerequisites

Be­fore you get start­ed, please make sure you have determined the eCR Viewer configuration your organization plans to use.

[Click here to view information about the available configurations.](https://cdcgov.github.io/dibbs-ecr-viewer/documents/Setup_Guide.html#general-background)

Please reach out if you have any questions about these options or need help deciding.

- You’ll need to have an account, per­missions, and necessary function­al­i­ty set up in AWS. 
- You’ll need to have access to the registered DIBBS VM AMI in your AWS account. 
- You’ll need to be able to create an S3 bucket set up in AWS to store your eCR data, with the prop­er net­work­ing and ac­cess pro­visions for EC2.
- You'll need to be able to create an EC2 instance.
- You’ll need to have a data­base set up (on-premise or cloud-based, Microsoft SQL or  Post­gre­SQL) and ac­ces­si­ble via the AWS net­work. 
- You’ll need to have an Entra, or Key­cloak client created or NBS authentication for the eCR View­er ap­pli­cation.


## Database Setup (Only required for NON_INTEGRATED and DUAL configurations)

The database setup is very jurisdiction dependent so we're going to forego specific setup instructions. You should follow all of your local jurisdictions policies and procedures for database setup. 

The eCR View­er can be con­figured to in­ter­face with an in­stance of Post­gre­SQL or Microsoft SQL Server for stor­age and retrieval of data. This data­base in­stance can be either cloud-based or lo­cat­ed on-premises. Your Post­gre­SQL in­stance needs to meet the fol­low­ing requirements:

- Must be reach­able over the net­work, either with­in your AWS account, via net­work peering to an­oth­er AWS account, or via a net­work route to your on premise in­stance. 
- Must have prop­er backups/snap­shots con­figured, to al­low for roll­backs in case of a failed migration or oth­er data in­con­sis­ten­cy. 
- Must fol­low prop­er retention policies and au­dit logging as re­quired by your ju­ris­diction’s applicable laws, statutes, and regulations. 

We strong­ly rec­om­mend cre­at­ing a ded­i­cat­ed data­base user for use by the eCR Viewer application. Once you have cre­at­ed this user, en­sure that their per­missions are prop­er­ly scoped to the least privilege in ac­cor­dance with your in­ter­nal policies. The user will need to be able to create and modify tables and schemas on the database you use.

Then, take note of the user­name and pass­word for this user. You will need these val­ues for the vir­tu­al ma­chine’s set­up process.

## Entra or Keycloak Setup (Only required for NON_INTEGRATED and DUAL configurations)

To in­te­grate the eCR View­er with your ex­ist­ing Entra or Key­cloak in­stance, you will need to cre­ate a new registration for the View­er ap­pli­cation. You don’t have to con­fig­ure groups and roles at this time; user per­missions are cur­rent­ly man­aged with­in the eCR View­er in­ter­face. 

Take note of the client ID, client secret, and is­suer in­formation. You will need these val­ues  when you per­form initial con­fig­u­ration of the VM in­stance.

## Permissions

Your vir­tu­al ma­chine instance will need permissions and network access to the S3 Bucket, the Database (if applicable), and Entra or Keycloak (if applicable) to function correctly.

## Portainer  

We’ve included a copy of Por­tain­er in the eCR View­er stack. This ap­pli­cation will al­low you to man­age Dock­er us­ing a web-based GUI, where you can con­fig­ure re­sources, view logs, and  per­form oth­er ad­ministrative actions.

Once you've setup your VM, vis­it http://<VM_AD­DRESS>:9000 in your brows­er of choice. It is recommended that you restrict access to Portainer using security groups, allowing only the administrator IP port access when needed.

[Click here for official docs re­gard­ing Por­tain­er’s functions.](https://docs.portainer.io/)

## Additional Security Steps  

We strong­ly rec­om­mend lock­ing down your VM in­stance in ac­cor­dance with your ju­ris­diction's  applicable policies, regulations, and statutes. 

Steps to con­sid­er include:

- Activate a fire­wall with­in AWS.
- Ensure Security Groups are restrictive.
- Opt out of a public IP if possible.
- Con­fig­ure IP ac­cess restrictions. 
- Re­strict SSH ac­cess. 
- Route traffic to the VM through a load balancer or gate­way. 

## Required Ports  

If you choose to implement a fire­wall, please note that the fol­low­ing are in use by the eCR View­er con­tain­er stack: 

- eCR View­er: 
Port: 3000
This is the ingress for the eCR Viewer applications.

- Por­tai­ner management console:
Port: 9000
This is an admin console that should not be generally available, ensure it's secure and only made available if or when it's needed.

--

- **Version 1.0.0** 

- **We're humans writing docs, if you see an issue or wish something was clearer, [let us know!](https://github.com/CDCgov/dibbs-vm/issues/new/choose)**