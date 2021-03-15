# Caravan Infra gcp

![Caravan 2021 GCP](https://lucid.app/publicSegments/view/6c88c233-6065-4c65-abcd-ec9a4d8de080/image.png)

## Module description

The purpose of this module is deploying the Caravan infrastructure upon which the Caravan cluster will reside.

The code will deploy components formed by the following graph.

## Prepare

The `project-setup.sh` script help you to create all the necessary requirements to deploy the infrastructure.

`./project-setup.sh XXXXXX-YYYYYY-ZZZZZZ 12345678901 admin-project-example project-example-id project-example us-central1`

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| terraform | ~> 0.14.7 |

## Providers

| Name | Version |
|------|---------|
| google | n/a |
| local | n/a |
| null | n/a |
| random | n/a |
| tls | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| caravan-bootstrap | git::ssh://git@github.com/bitrockteam/caravan-bootstrap?ref=refs/tags/v0.2.1 |  |
| cloud_init_control_plane | git::ssh://git@github.com/bitrockteam/caravan-cloudinit?ref=refs/tags/v0.1.4 |  |
| cloud_init_worker_plane | git::ssh://git@github.com/bitrockteam/caravan-cloudinit?ref=refs/tags/v0.1.4 |  |
| terraform-acme-le | git::ssh://git@github.com/bitrockteam/caravan-acme-le?ref=refs/tags/v0.0.1 |  |

## Resources

| Name |
|------|
| [google_client_openid_userinfo](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/client_openid_userinfo) |
| [google_compute_backend_service](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_backend_service) |
| [google_compute_firewall](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) |
| [google_compute_global_forwarding_rule](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_global_forwarding_rule) |
| [google_compute_health_check](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_health_check) |
| [google_compute_instance](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance) |
| [google_compute_instance_group](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance_group) |
| [google_compute_instance_template](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance_template) |
| [google_compute_network](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_network) |
| [google_compute_region_disk](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_region_disk) |
| [google_compute_region_instance_group_manager](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_region_instance_group_manager) |
| [google_compute_router](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_router) |
| [google_compute_router_nat](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_router_nat) |
| [google_compute_ssl_certificate](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_ssl_certificate) |
| [google_compute_ssl_policy](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_ssl_policy) |
| [google_compute_subnetwork](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_subnetwork) |
| [google_compute_target_https_proxy](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_target_https_proxy) |
| [google_compute_url_map](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_url_map) |
| [google_compute_zones](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_zones) |
| [google_dns_managed_zone](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/dns_managed_zone) |
| [google_dns_managed_zone](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/dns_managed_zone) |
| [google_dns_record_set](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/dns_record_set) |
| [google_kms_crypto_key](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/kms_crypto_key) |
| [google_kms_key_ring](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/kms_key_ring) |
| [google_kms_key_ring_iam_binding](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/kms_key_ring_iam_binding) |
| [google_project_iam_binding](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_binding) |
| [google_project_iam_custom_role](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_custom_role) |
| [google_project_iam_member](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) |
| [google_project_service](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_service) |
| [google_service_account](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account) |
| [google_service_account_iam_binding](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account_iam_binding) |
| [google_storage_bucket](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket) |
| [google_storage_bucket_iam_binding](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket_iam_binding) |
| [local_file](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) |
| [null_resource](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) |
| [random_id](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) |
| [tls_private_key](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| admins | List of admins to add to the project | `list(string)` | `[]` | no |
| allowed\_ip\_list | IP address list for SSH connection to the VMs | `list(string)` | <pre>[<br>  "0.0.0.0/0"<br>]</pre> | no |
| base64 | Cloud init decoding | `bool` | `false` | no |
| ca\_certs | Fake certificates from staging Let's Encrypt | <pre>map(object({<br>    filename = string<br>    pemurl   = string<br>  }))</pre> | <pre>{<br>  "fakeleintermediatex1": {<br>    "filename": "fakeleintermediatex1.pem",<br>    "pemurl": "https://letsencrypt.org/certs/fakeleintermediatex1.pem"<br>  },<br>  "fakelerootx1": {<br>    "filename": "fakelerootx1.pem",<br>    "pemurl": "https://letsencrypt.org/certs/fakelerootx1.pem"<br>  }<br>}</pre> | no |
| consul\_license\_file | Path to Consul Enterprise license | `string` | `null` | no |
| control\_plane\_instance\_count | Control plane instances number | `string` | `"3"` | no |
| control\_plane\_machine\_type | Control plane instance machine type | `string` | `"e2-standard-2"` | no |
| control\_plane\_sa\_name | Control plane service account name, it will be used by Vault Auth method | `string` | `"control-plane"` | no |
| csi\_volumes | Example:<br>{<br>  "jenkins" : {<br>    "type" : "pd-ssd"<br>    "size" : "30"<br>    "replica\_zones" : ["us-central1-a", "us-central1-b"]<br>    "tags" : { "application": "jenkins\_master" }<br>  }<br>} | `map(map(string))` | `{}` | no |
| dc\_name | Hashicorp cluster name | `string` | `"gcp-dc"` | no |
| enable\_monitoring | Enables and setup monitoring node | `bool` | `true` | no |
| external\_domain | Domain used for endpoints and certs | `string` | `""` | no |
| google\_account\_file | Path to Google account file | `string` | n/a | yes |
| google\_kms\_crypto\_key | GCP KMS crypto key | `string` | `""` | no |
| google\_kms\_key\_ring | GCP KMS key ring | `string` | `""` | no |
| gzip | Cloud init compressing | `bool` | `false` | no |
| image | Fully qualified image name | `string` | n/a | yes |
| le\_production\_endpoint | LE's endpoint when use\_le\_staging==false | `string` | `"https://acme-v02.api.letsencrypt.org/directory"` | no |
| le\_staging\_endpoint | LE's endpoint when use\_le\_staging==true | `string` | `"https://acme-staging-v02.api.letsencrypt.org/directory"` | no |
| nomad\_license\_file | Path to Nomad Enterprise license | `string` | `null` | no |
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
| vault\_license\_file | Path to Vault Enterprise license | `string` | `null` | no |
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
| csi\_volumes | n/a |
| hashicorp\_endpoints | Hashicorp clusters endpoints |
| load-balancer-ip-address | Load Balancer IP address |
| project\_id | GCP project ID |
| worker\_plane\_role\_name | Worker plane role name |
| worker\_plane\_service\_account | Worker plane service account |
| worker\_plane\_service\_accounts | Worker plane service accounts email list |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Cleaning up

After `terraform destroy -var-file=gcp.tfvars`, for removing left resources and project, run the `project-cleanup.sh` script:

```bash
./project-cleanup.sh <PROJECT_ID> <PARENT_PROJECT_ID>
```
