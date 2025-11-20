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
- You’ll need to be able to create an S3 bucket set up in AWS to store your eCR data, with the prop­er net­work­ing and ac­cess pro­vi­sions for EC2.
- You'll need to be able to create an EC2 instance.
- You’ll need to have a data­base set up (on-premise or cloud-based, Mi­crosoft SQL or  Post­gre­SQL) and ac­ces­si­ble via the AWS net­work. 
- You’ll need to have an Entra, or Key­cloak client created or NBS authentication for the eCR View­er ap­pli­ca­tion.
- You’ll need to have IAM permissions to make adjustments within your AWS en­vi­ron­ment.


## Database Setup (Only required for NON_INTEGRATED and DUAL configurations)

The database setup is very juristiction dependent so we're going to forego specific setup instructions. You should follow all of your local juristictions policies and procedures for database setup. 

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

## Portainer Setup  

We’ve in­clud­ed a copy of Por­tain­er in the eCR View­er stack. This ap­pli­ca­tion will al­low you to  man­age Dock­er us­ing a web-based GUI, where you can con­fig­ure re­sources, view logs, and  per­form oth­er ad­min­is­tra­tive ac­tions.

Once you've setup your VM, vis­it http://<VM_AD­DRESS>:9000 in your brows­er of choice. It is recommended that you restrict access to Portainer using security groups, allowing only the administrator IP access when needed. Click here for official docs re­gard­ing Por­tain­er’s func­tions.

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

--

- **Version 1.0.0** 

- **We're humans writing docs, if you see an issue or wish something was clearer, [let us know!](https://github.com/CDCgov/dibbs-vm/issues/new/choose)**