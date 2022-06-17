# skillsmap-infra-8
Skillsmap cloud/infra tab, exercise line 8

# Task
on AWS  
create EC2 instance with Public IP on it  
add security group for ssh, ICMP (ping) and http/https  
create fqdn dns entry on domain (use one available on r53, no need to buy one)  
get a valid ssl cert for dns entry  
configure a nginx web  
test certificate works - on a desktop browser padlock closes  

# Usage
Git clone
```
git clone https://github.com/paulboekschoten/skillsmap-infra-9.git
```

Change directory
```
cd skillsmap-infra-9
```

# Check variables are correct in terraform.tfvars  
Set your values for cert_email, route53_zone and route53_subdomain.
```
cert_email        = "paul.boekschoten@hashicorp.com"
route53_zone      = "tf-support.hashicorpdemo.com"
route53_subdomain = "cloudinfrapaultf"
```  
  

# Terraform init
```
terraform init
```
Sample output
```
Initializing the backend...

Initializing provider plugins...
- Finding latest version of hashicorp/null...
- Finding vancluever/acme versions matching "2.8.0"...
- Finding latest version of hashicorp/aws...
- Finding latest version of hashicorp/tls...
- Using hashicorp/null v3.1.1 from the shared cache directory
- Using vancluever/acme v2.8.0 from the shared cache directory
- Using hashicorp/aws v4.19.0 from the shared cache directory
- Using hashicorp/tls v3.4.0 from the shared cache directory

Terraform has created a lock file .terraform.lock.hcl to record the provider
selections it made above. Include this file in your version control repository
so that Terraform can guarantee to make the same selections by default when
you run "terraform init" in the future.

Terraform has been successfully initialized!

...
```
  

# Terraform apply
```
terraform apply
```
Sample output
```
...

Plan: 14 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + dns = (known after apply)

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: 
```
Answer with `yes` if your want to proceed.  

```
...

null_resource.config (remote-exec): No VM guests are running outdated
null_resource.config (remote-exec):  hypervisor (qemu) binaries on this
null_resource.config (remote-exec):  host.
null_resource.config: Creation complete after 20s [id=4126387254427133581]

Apply complete! Resources: 14 added, 0 changed, 0 destroyed.
```

# Output  
At the end you will also see an output  
```
Outputs:

dns = "cloudinfrapaultf.tf-support.hashicorpdemo.com"
```
If you visit this link on http ([http://cloudinfrapaultf.tf-support.hashicorpdemo.com/](http://cloudinfrapaultf.tf-support.hashicorpdemo.com/)) or https ([https://cloudinfrapaultf.tf-support.hashicorpdemo.com/](https://cloudinfrapaultf.tf-support.hashicorpdemo.com/)) you should see this
![](media/2022-06-15-10-38-14.png)  

With a valid certificate on https  
![](media/2022-06-15-10-39-47.png)  

# TODO / DONE
- [x] Add lockfile to gitignore
- [x] Check and reorder variables
- [x] Check outputs
- [x] Supplement this readme
- [x] Check destroy/apply
