# Caravan Infra gcp

## Module description

The purpose of this module is deploying the Caravan infrastructure upon which the Caravan cluster will reside.

The code will deploy components formed by the following graph.

## Terraform Resources Graph

![Terraform resources graph](images/graph.png)

## Prepare

The `project-setup.sh` script help you to create all the necessary requirements to deploy the infrastructure.

`./project-setup.sh XXXXXX-YYYYYY-ZZZZZZ 12345678901 admin-project-example project-example-id project-example us-central1`

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| terraform | ~> 0.13.1 |
| terraform | >= 0.13 |

## Providers

| Name | Version |
|------|---------|
| google | n/a |
| local | n/a |
| null | n/a |
| random | n/a |
| tls | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| admins | List of admins to add to the project | `list(string)` | `[]` | no |
| allowed\_ip\_list | IP address list for SSH connection to the VMs | `list(string)` | <pre>[<br>  "0.0.0.0/0"<br>]</pre> | no |
| base64 | Cloud init decoding | `bool` | `false` | no |
| ca\_certs | Fake certificates from staging Let's Encrypt | <pre>map(object({<br>    filename = string<br>    pemurl   = string<br>  }))</pre> | <pre>{<br>  "fakeleintermediatex1": {<br>    "filename": "fakeleintermediatex1.pem",<br>    "pemurl": "https://letsencrypt.org/certs/fakeleintermediatex1.pem"<br>  },<br>  "fakelerootx1": {<br>    "filename": "fakelerootx1.pem",<br>    "pemurl": "https://letsencrypt.org/certs/fakelerootx1.pem"<br>  }<br>}</pre> | no |
| control\_plane\_instance\_count | Control plane instances number | `string` | `"3"` | no |
| control\_plane\_machine\_type | Control plane instance machine type | `string` | `"e2-standard-2"` | no |
| control\_plane\_sa\_name | Control plane service account name, it will be used by Vault Auth method | `string` | `"control-plane"` | no |
| dc\_name | Hashicorp cluster name | `string` | `"gcp-dc"` | no |
| enable\_monitoring | Enables and setup monitoring node | `bool` | `true` | no |
| external\_domain | Domain used for endpoints and certs | `string` | `""` | no |
| gcp\_csi | Enable disk for Nomad CSI | `bool` | `true` | no |
| google\_account\_file | Path to Google account file | `string` | n/a | yes |
| google\_kms\_crypto\_key | GCP KMS crypto key | `string` | `""` | no |
| google\_kms\_key\_ring | GCP KMS key ring | `string` | `""` | no |
| gzip | Cloud init compressing | `bool` | `false` | no |
| image | Fully qualified image name | `string` | n/a | yes |
| le\_production\_endpoint | LE's endpoint when use\_le\_staging==false | `string` | `"https://acme-v02.api.letsencrypt.org/directory"` | no |
| le\_staging\_endpoint | LE's endpoint when use\_le\_staging==true | `string` | `"https://acme-staging-v02.api.letsencrypt.org/directory"` | no |
| parent\_dns\_project\_id | GCP parent project ID | `string` | `""` | no |
| parent\_dns\_zone\_name | GCP parent project DNS zone name | `string` | `"GCP"` | no |
| preemptible\_instance\_type | Sets preemptible instance type | `bool` | `false` | no |
| prefix | The prefix of the objects' names | `string` | `""` | no |
| project\_id | GCP Project ID | `string` | n/a | yes |
| region | GCP region where to deploy the cluster | `string` | `"us-central1"` | no |
| ssh\_timeout | SSH timeout | `string` | `"240s"` | no |
| ssh\_user | SSH user | `string` | `"centos"` | no |
| subnet\_prefix | The address prefix to use for the subnet | `string` | `"10.128.0.0/28"` | no |
| use\_le\_staging | Use staging Let's Encrypt endpoint | `bool` | `false` | no |
| worker\_plane\_machine\_type | Worker plane instance machine type | `string` | `"n2-standard-2"` | no |
| worker\_plane\_sa\_name | Worker plane service account name, it will be used by Vault Auth method | `string` | `"worker-plane"` | no |
| workers\_groups | Worker instance group map | `map(any)` | <pre>{<br>  "workers-group": {<br>    "base_instance_name": "worker",<br>    "instance_template": "worker-template",<br>    "target_size": 3,<br>    "zone": "us-central1-a"<br>  }<br>}</pre> | no |
| workers\_instance\_templates | Worker instance template map | `map(any)` | <pre>{<br>  "worker-template": {<br>    "image_family_name": "centos-image",<br>    "machine_type": "n1-standard-2",<br>    "name_prefix": "worker-template-default-",<br>    "preemptible": false<br>  }<br>}</pre> | no |
| zone | GCP zone | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| PROJECT\_APPSUPP\_TFVAR | Caravan Application Support tfvars |
| PROJECT\_PLATFORM\_TFVAR | Caravan Platform tfvars |
| PROJECT\_WORKLOAD\_TFVAR | Caravan Workload tfvars |
| ca\_certs | Let's Encrypt staging CA certificates |
| cluster-public-ips | Control plane public IP addresses |
| control\_plane\_role\_name | Control plane role name |
| control\_plane\_service\_accounts | Control plane service accounts email list |
| hashicorp\_endpoints | Hashicorp clusters endpoints |
| load-balancer-ip-address | Load Balancer IP address |
| pd\_ssd\_jenkins\_master\_id | Persistent Disk ID for Jenkins Master |
| project\_id | GCP project ID |
| worker\_plane\_role\_name | Worker plane role name |
| worker\_plane\_service\_account | Worker plane service account |
| worker\_plane\_service\_accounts | Worker plane service accounts email list |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
