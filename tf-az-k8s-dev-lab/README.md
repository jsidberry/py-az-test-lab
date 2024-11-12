## What does this code do?
This creates a RHEL9 VM that is running Event Driven Ansible or EDA. 

## Steps to cleanly execute this code/configuration

1. Download/Clone this repo: 
```bash
git clone git@bitbucket.org:insightglobal/prod-ops.git
```

2. Navigate into the Terrafrom for K8s directory: 
```bash
cd prod-ops/tf-az-k8s-dev-lab
```

3. Copy the `example.tfvars` file `k8s.tfvars`: 
```bash
cp example-tfvars k8s.tfvars
```

4. Here, you are going to change the values within the `k8s.tfvars` file. You can change things to whatever you want; **however**, to keep it simple, you can use all the existing values except the following. These are the only values you **MUST** supply:

```bash
supportcontact = ""
admin_username = ""
```

Below are suggested commands to use. This will name the user account on the VM and match the user account on your Macbook Pro or on your local Linux host (depending from where you are running this): 

```bash
sed "s/supportcontact = \"\"/supportcontact = \"$(whoami)\"/" k8s.tfvars
sed "s/admin_username = \"\"/admin_username = \"$(whoami)\"/" k8s.tfvars
```

5. Now your code is ready to build out you K8S host. Run the following commands:
```bash
terraform init
terraform plan -var-file="k8s.tfvars"
terraform apply -auto-approve -var-file="k8s.tfvars"
```
6. At the end of the deployment you will see an IP address output. That is the Public IP address so that you can log into the VM from you local laptop. It will look something like this:
```bash
Outputs:

public_ip_address = "52.xxx.xxx.167"
```
7. Now you are ready to log into your Newly minted VM build in our Azure Sandbox:
```bash
ssh <username>@52.xxx.xxx.167
```

## Clean up

When you are done playing with the EDA in the Sandbox, you can (and should) destroy it. Do not do this manually in the Azure Portal. Please use the Terraform command below:
```bash
terraform destroy -auto-approve -var-file="k8s.tfvars"
```