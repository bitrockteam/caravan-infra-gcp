# Caravan Infra GCP

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
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.0 |
| <a name="requirement_google"></a> [google](#requirement\_google) | ~> 4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | 4.33.0 |
| <a name="provider_local"></a> [local](#provider\_local) | 2.2.3 |
| <a name="provider_null"></a> [null](#provider\_null) | 3.1.1 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.3.2 |
| <a name="provider_tls"></a> [tls](#provider\_tls) | 4.0.1 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_caravan-bootstrap"></a> [caravan-bootstrap](#module\_caravan-bootstrap) | git::https://github.com/bitrockteam/caravan-bootstrap | refs/tags/v0.2.19 |
| <a name="module_cloud_init_control_plane"></a> [cloud\_init\_control\_plane](#module\_cloud\_init\_control\_plane) | git::https://github.com/bitrockteam/caravan-cloudinit | refs/tags/v0.1.18 |
| <a name="module_cloud_init_worker_plane"></a> [cloud\_init\_worker\_plane](#module\_cloud\_init\_worker\_plane) | git::https://github.com/bitrockteam/caravan-cloudinit | refs/tags/v0.1.18 |
| <a name="module_terraform-acme-le"></a> [terraform-acme-le](#module\_terraform-acme-le) | git::https://github.com/bitrockteam/caravan-acme-le | refs/tags/v0.0.16 |

## Resources

| Name | Type |
|------|------|
| [google_compute_attached_disk.consul_data](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_attached_disk) | resource |
| [google_compute_attached_disk.nomad_data](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_attached_disk) | resource |
| [google_compute_attached_disk.vault_data](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_attached_disk) | resource |
| [google_compute_backend_service.backend_service_consul](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_backend_service) | resource |
| [google_compute_backend_service.backend_service_nomad](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_backend_service) | resource |
| [google_compute_backend_service.backend_service_vault](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_backend_service) | resource |
| [google_compute_backend_service.backend_service_workload](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_backend_service) | resource |
| [google_compute_disk.consul_data](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_disk) | resource |
| [google_compute_disk.nomad_data](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_disk) | resource |
| [google_compute_disk.vault_data](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_disk) | resource |
| [google_compute_firewall.hashicorp_allow_ssh](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_firewall.hashicorp_cluster](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_firewall.hashicorp_ingress](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_firewall.hashicorp_internal_consul_ha](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_firewall.hashicorp_internal_ha](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_firewall.hashicorp_internal_nomad_ha](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_global_forwarding_rule.global_forwarding_rule](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_global_forwarding_rule) | resource |
| [google_compute_health_check.healthcheck_consul](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_health_check) | resource |
| [google_compute_health_check.healthcheck_nomad](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_health_check) | resource |
| [google_compute_health_check.healthcheck_tcp_ingress](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_health_check) | resource |
| [google_compute_health_check.healthcheck_vault](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_health_check) | resource |
| [google_compute_instance.hashicorp_cluster_nodes](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance) | resource |
| [google_compute_instance.monitoring_instance](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance) | resource |
| [google_compute_instance_group.hashicorp_cluster_nodes](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance_group) | resource |
| [google_compute_instance_template.worker-instance-template](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance_template) | resource |
| [google_compute_network.hashicorp](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_network) | resource |
| [google_compute_region_disk.csi](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_region_disk) | resource |
| [google_compute_region_instance_group_manager.default_workers](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_region_instance_group_manager) | resource |
| [google_compute_router.router](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_router) | resource |
| [google_compute_router_nat.nat](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_router_nat) | resource |
| [google_compute_ssl_certificate.lb_certificate](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_ssl_certificate) | resource |
| [google_compute_ssl_policy.modern_tls_1_2_ssl_policy](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_ssl_policy) | resource |
| [google_compute_subnetwork.hashicorp](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_subnetwork) | resource |
| [google_compute_target_https_proxy.target_https_proxy](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_target_https_proxy) | resource |
| [google_compute_url_map.url_map](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_url_map) | resource |
| [google_dns_managed_zone.project-zone](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/dns_managed_zone) | resource |
| [google_dns_record_set.a-hc](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/dns_record_set) | resource |
| [google_dns_record_set.cname-consul](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/dns_record_set) | resource |
| [google_dns_record_set.cname-nomad](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/dns_record_set) | resource |
| [google_dns_record_set.cname-vault](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/dns_record_set) | resource |
| [google_dns_record_set.cname-wild](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/dns_record_set) | resource |
| [google_dns_record_set.projects-ns](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/dns_record_set) | resource |
| [google_kms_crypto_key.vault_key](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/kms_crypto_key) | resource |
| [google_kms_key_ring.vault_keyring](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/kms_key_ring) | resource |
| [google_kms_key_ring_iam_binding.vault_iam_kms_binding](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/kms_key_ring_iam_binding) | resource |
| [google_project_iam_binding.pd_csi_service_account_iam_binding](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_binding) | resource |
| [google_project_iam_binding.pd_csi_service_account_storage_admin_iam_binding](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_binding) | resource |
| [google_project_iam_binding.pd_csi_service_account_user_iam_binding](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_binding) | resource |
| [google_project_iam_custom_role.gcp_compute_persistent_disk_csi_driver](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_custom_role) | resource |
| [google_project_iam_member.project](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_project_service.cloudkms](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_service) | resource |
| [google_project_service.cloudresourcemanager](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_service) | resource |
| [google_project_service.compute](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_service) | resource |
| [google_project_service.dns](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_service) | resource |
| [google_project_service.iam](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_service) | resource |
| [google_project_service.logging](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_service) | resource |
| [google_project_service.monitoring](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_service) | resource |
| [google_project_service.serviceusage](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_service) | resource |
| [google_service_account.control_plane_service_account](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account) | resource |
| [google_service_account.pd_csi_service_account](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account) | resource |
| [google_service_account.worker_plane_service_account](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account) | resource |
| [google_service_account_iam_binding.key_account_iam](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account_iam_binding) | resource |
| [google_service_account_iam_binding.key_account_iam_control_plane](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account_iam_binding) | resource |
| [google_service_account_iam_binding.key_account_iam_workers](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account_iam_binding) | resource |
| [google_service_account_key.pd_csi_sa_key](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account_key) | resource |
| [google_storage_bucket.configs](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket) | resource |
| [google_storage_bucket_iam_binding.configs_binding](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket_iam_binding) | resource |
| [local_file.backend_tf_appsupport](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [local_file.backend_tf_platform](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [local_file.tfvars_appsupport](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [local_file.tfvars_platform](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [local_sensitive_file.ssh_key](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/sensitive_file) | resource |
| [null_resource.ca_certs](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.ca_certs_bundle](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [random_id.keyring](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |
| [random_id.random](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |
| [tls_private_key.cert_private_key](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |
| [tls_private_key.ssh-key](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |
| [google_client_openid_userinfo.myself](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/client_openid_userinfo) | data source |
| [google_compute_zones.available](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_zones) | data source |
| [google_dns_managed_zone.parent-zone](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/dns_managed_zone) | data source |
| [google_project.project](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/project) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_google_account_file"></a> [google\_account\_file](#input\_google\_account\_file) | Path to Google account file | `string` | n/a | yes |
| <a name="input_image"></a> [image](#input\_image) | Fully qualified image name | `string` | n/a | yes |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | GCP Project ID | `string` | n/a | yes |
| <a name="input_zone"></a> [zone](#input\_zone) | GCP zone | `string` | n/a | yes |
| <a name="input_admins"></a> [admins](#input\_admins) | List of admins to add to the project | `list(string)` | `[]` | no |
| <a name="input_allowed_ip_list"></a> [allowed\_ip\_list](#input\_allowed\_ip\_list) | IP address list for SSH connection to the VMs | `list(string)` | <pre>[<br>  "0.0.0.0/0"<br>]</pre> | no |
| <a name="input_base64"></a> [base64](#input\_base64) | Cloud init decoding | `bool` | `false` | no |
| <a name="input_ca_certs"></a> [ca\_certs](#input\_ca\_certs) | Fake certificates from staging Let's Encrypt | <pre>map(object({<br>    filename = string<br>    pemurl   = string<br>  }))</pre> | <pre>{<br>  "stg-int-r3": {<br>    "filename": "letsencrypt-stg-int-r3.pem",<br>    "pemurl": "https://letsencrypt.org/certs/staging/letsencrypt-stg-int-r3.pem"<br>  },<br>  "stg-root-x1": {<br>    "filename": "letsencrypt-stg-root-x1.pem",<br>    "pemurl": "https://letsencrypt.org/certs/staging/letsencrypt-stg-root-x1.pem"<br>  }<br>}</pre> | no |
| <a name="input_consul_license_file"></a> [consul\_license\_file](#input\_consul\_license\_file) | Path to Consul Enterprise license | `string` | `null` | no |
| <a name="input_control_plane_instance_count"></a> [control\_plane\_instance\_count](#input\_control\_plane\_instance\_count) | Control plane instances number | `string` | `"3"` | no |
| <a name="input_control_plane_machine_type"></a> [control\_plane\_machine\_type](#input\_control\_plane\_machine\_type) | Control plane instance machine type | `string` | `"e2-standard-2"` | no |
| <a name="input_control_plane_sa_name"></a> [control\_plane\_sa\_name](#input\_control\_plane\_sa\_name) | Control plane service account name, it will be used by Vault Auth method | `string` | `"control-plane"` | no |
| <a name="input_csi_volumes"></a> [csi\_volumes](#input\_csi\_volumes) | Example:<br>{<br>  "jenkins" : {<br>    "type" : "pd-ssd"<br>    "size" : "30"<br>    "replica\_zones" : ["us-central1-a", "us-central1-b"]<br>    "tags" : { "application": "jenkins\_master" }<br>  }<br>} | `map(map(string))` | `{}` | no |
| <a name="input_dc_name"></a> [dc\_name](#input\_dc\_name) | Hashicorp cluster name | `string` | `"gcp-dc"` | no |
| <a name="input_enable_monitoring"></a> [enable\_monitoring](#input\_enable\_monitoring) | Enables and setup monitoring node | `bool` | `true` | no |
| <a name="input_enable_nomad"></a> [enable\_nomad](#input\_enable\_nomad) | Enables and setup Nomad cluster | `bool` | `true` | no |
| <a name="input_external_domain"></a> [external\_domain](#input\_external\_domain) | Domain used for endpoints and certs | `string` | `""` | no |
| <a name="input_google_kms_crypto_key"></a> [google\_kms\_crypto\_key](#input\_google\_kms\_crypto\_key) | GCP KMS crypto key | `string` | `""` | no |
| <a name="input_google_kms_key_ring"></a> [google\_kms\_key\_ring](#input\_google\_kms\_key\_ring) | GCP KMS key ring | `string` | `""` | no |
| <a name="input_gzip"></a> [gzip](#input\_gzip) | Cloud init compressing | `bool` | `false` | no |
| <a name="input_le_production_endpoint"></a> [le\_production\_endpoint](#input\_le\_production\_endpoint) | LE's endpoint when use\_le\_staging==false | `string` | `"https://acme-v02.api.letsencrypt.org/directory"` | no |
| <a name="input_le_staging_endpoint"></a> [le\_staging\_endpoint](#input\_le\_staging\_endpoint) | LE's endpoint when use\_le\_staging==true | `string` | `"https://acme-staging-v02.api.letsencrypt.org/directory"` | no |
| <a name="input_nomad_license_file"></a> [nomad\_license\_file](#input\_nomad\_license\_file) | Path to Nomad Enterprise license | `string` | `null` | no |
| <a name="input_parent_dns_project_id"></a> [parent\_dns\_project\_id](#input\_parent\_dns\_project\_id) | GCP parent project ID | `string` | `""` | no |
| <a name="input_parent_dns_zone_name"></a> [parent\_dns\_zone\_name](#input\_parent\_dns\_zone\_name) | GCP parent project DNS zone name | `string` | `"GCP"` | no |
| <a name="input_preemptible_instance_type"></a> [preemptible\_instance\_type](#input\_preemptible\_instance\_type) | Sets preemptible instance type | `bool` | `false` | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | The prefix of the objects' names | `string` | `""` | no |
| <a name="input_region"></a> [region](#input\_region) | GCP region where to deploy the cluster | `string` | `"us-central1"` | no |
| <a name="input_ssh_timeout"></a> [ssh\_timeout](#input\_ssh\_timeout) | SSH timeout | `string` | `"240s"` | no |
| <a name="input_ssh_user"></a> [ssh\_user](#input\_ssh\_user) | SSH user | `string` | `"centos"` | no |
| <a name="input_subnet_prefix"></a> [subnet\_prefix](#input\_subnet\_prefix) | The address prefix to use for the subnet | `string` | `"10.128.0.0/28"` | no |
| <a name="input_use_le_staging"></a> [use\_le\_staging](#input\_use\_le\_staging) | Use staging Let's Encrypt endpoint | `bool` | `false` | no |
| <a name="input_vault_license_file"></a> [vault\_license\_file](#input\_vault\_license\_file) | Path to Vault Enterprise license | `string` | `null` | no |
| <a name="input_volume_data_size"></a> [volume\_data\_size](#input\_volume\_data\_size) | Volume size of control plan data disk | `number` | `20` | no |
| <a name="input_volume_data_type"></a> [volume\_data\_type](#input\_volume\_data\_type) | Volume type of data disks | `string` | `"pd-balanced"` | no |
| <a name="input_volume_root_size"></a> [volume\_root\_size](#input\_volume\_root\_size) | Volume size of control plan root disk | `number` | `20` | no |
| <a name="input_volume_root_type"></a> [volume\_root\_type](#input\_volume\_root\_type) | Volume type of root disks | `string` | `"pd-standard"` | no |
| <a name="input_worker_plane_machine_type"></a> [worker\_plane\_machine\_type](#input\_worker\_plane\_machine\_type) | Worker plane instance machine type | `string` | `"n2-standard-2"` | no |
| <a name="input_worker_plane_sa_name"></a> [worker\_plane\_sa\_name](#input\_worker\_plane\_sa\_name) | Worker plane service account name, it will be used by Vault Auth method | `string` | `"worker-plane"` | no |
| <a name="input_workers_groups"></a> [workers\_groups](#input\_workers\_groups) | Worker instance group map | `map(any)` | <pre>{<br>  "workers-group": {<br>    "base_instance_name": "worker",<br>    "instance_template": "worker-template",<br>    "target_size": 3,<br>    "zone": "us-central1-a"<br>  }<br>}</pre> | no |
| <a name="input_workers_instance_templates"></a> [workers\_instance\_templates](#input\_workers\_instance\_templates) | Worker instance template map | `map(any)` | <pre>{<br>  "worker-template": {<br>    "image_family_name": "centos-image",<br>    "machine_type": "n1-standard-2",<br>    "name_prefix": "worker-template-default-",<br>    "preemptible": false<br>  }<br>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_PROJECT_APPSUPP_TFVAR"></a> [PROJECT\_APPSUPP\_TFVAR](#output\_PROJECT\_APPSUPP\_TFVAR) | Caravan Application Support tfvars |
| <a name="output_PROJECT_PLATFORM_TFVAR"></a> [PROJECT\_PLATFORM\_TFVAR](#output\_PROJECT\_PLATFORM\_TFVAR) | Caravan Platform tfvars |
| <a name="output_PROJECT_WORKLOAD_TFVAR"></a> [PROJECT\_WORKLOAD\_TFVAR](#output\_PROJECT\_WORKLOAD\_TFVAR) | Caravan Workload tfvars |
| <a name="output_ca_certs"></a> [ca\_certs](#output\_ca\_certs) | Let's Encrypt staging CA certificates |
| <a name="output_cluster-public-ips"></a> [cluster-public-ips](#output\_cluster-public-ips) | Control plane public IP addresses |
| <a name="output_control_plane_role_name"></a> [control\_plane\_role\_name](#output\_control\_plane\_role\_name) | Control plane role name |
| <a name="output_control_plane_service_accounts"></a> [control\_plane\_service\_accounts](#output\_control\_plane\_service\_accounts) | Control plane service accounts email list |
| <a name="output_csi_sa_key"></a> [csi\_sa\_key](#output\_csi\_sa\_key) | n/a |
| <a name="output_csi_volumes"></a> [csi\_volumes](#output\_csi\_volumes) | n/a |
| <a name="output_hashicorp_endpoints"></a> [hashicorp\_endpoints](#output\_hashicorp\_endpoints) | Hashicorp clusters endpoints |
| <a name="output_load-balancer-ip-address"></a> [load-balancer-ip-address](#output\_load-balancer-ip-address) | Load Balancer IP address |
| <a name="output_project_id"></a> [project\_id](#output\_project\_id) | GCP project ID |
| <a name="output_worker_plane_role_name"></a> [worker\_plane\_role\_name](#output\_worker\_plane\_role\_name) | Worker plane role name |
| <a name="output_worker_plane_service_account"></a> [worker\_plane\_service\_account](#output\_worker\_plane\_service\_account) | Worker plane service account |
| <a name="output_worker_plane_service_accounts"></a> [worker\_plane\_service\_accounts](#output\_worker\_plane\_service\_accounts) | Worker plane service accounts email list |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Cleaning up

After `terraform destroy -var-file=gcp.tfvars`, for removing left resources and project, run the `project-cleanup.sh` script:

```bash
./project-cleanup.sh <PROJECT_ID> <PARENT_PROJECT_ID>
```
