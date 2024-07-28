## Overall

This module will deploy OpenShift with calico based on the main branch on the KVM hypervisor through Terraform Libvirt and aicli (https://github.com/karmab/aicli). It currently works with https://github.com/isovalent/terraform-equinix-infra modules to create the OpenShift VMs on Equinix Metal. In theory, it should work with any KVM hypervisor and may need more tweaks.

A lot of predefined configurations from the terraform-equinix-infra module on the router are for this module to deliver a seamless user experience when consuming OpenShift.

## Example to deploy OpenShift on Equinix

Please consider this example as your starting point to get OpenShift running on Equinix:

```hcl
module "infra" {
  source           = "git::https://github.com/isovalent/terraform-equinix-infra"
  api_key          = var.api_key
  infra_name       = "test"
  k8s_cluster_name = "liyi-ocp"
}

module "ocp" {
  source                         = "git::https://github.com/isovalent/terraform-libvirt-openshift"
  ocp_offline_token              = var.ocp_offline_token
  path_to_ocp_pull_secret        = "./pull-secret.txt"
  ocp_base_domain                = module.infra.dns_base_domain
  ocp_cluster_name               = module.infra.k8s_cluster_name
  ocp_masters_count              = module.infra.k8s_master_count
  ocp_workers_count              = module.infra.k8s_worker_count
  kvm_host_ip_address            = module.infra.host-public-ip-address
  path_to_kvm_host_login_ssh_key = module.infra.ssh_private_key_file_path
  path_to_ocp_setup_private_key  = module.infra.ssh_private_key_file_path
  calico_version                 = "3.28.0"
  libvirt_volume_main_name       = module.infra.libvirt_pool_main_name
  libvirt_private_network_id     = module.infra.libvirt_private_network_id
  private_network_ipv4_cidr      = module.infra.private_network_ipv4_cidr
  private_network_ipv6_cidr      = module.infra.private_network_ipv6_cidr
  ocp_master_ip_mac_hostname_map = module.infra.k8s_master_ip_mac_hostname_map
  ocp_worker_ip_mac_hostname_map = module.infra.k8s_worker_ip_mac_hostname_map
  kube_api_server_ip             = module.infra.router-public-ip-address
}
```

You need an account at https://console.redhat.com/ to get the pull secrets and the ocp_offline_token.

You need to run `terraform apply --target=module.infra` and `terraform apply` in 2 separate steps to avoid the dependency issue between the 2 modules.

After running it, it will take around 60 minutes to get the cluster up and running, and you can check https://console.redhat.com/openshift for the deployment status.

## Notes
* OpenShift VMs are on the private network and use the router from the terraform-equinix-infra module as the gateway. If you would like to access the OpenShift VM through SSH, you will need to SSH to the testbox from the terraform-equinix-infra module as the jumpbox.

* The SSH key to the OpenShift VM and OpenShift setup manifest are on the hypervisor in the /aicli/ directory.
* The router in the terraform-equinix-infra module has preconfigured the HA proxy for ports 6443, 443, and 80, so it will forward the traffic to OpenShift without any configuration from you.
* Because we have a private FQDN which is only valid on the private network, we have a `post_install_script` to override your local `/etc/hosts` file to route the traffic to the router if you use the variable `kube_api_server_ip` with the router's public IP address.


## Output of this modules
After running this module, the kubeconfig path will be output and you can access the API server through kubectl. In the same directory, you can also find the kubeadmin password so you can access the GUI of OpenShift.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.6.5 |
| <a name="requirement_libvirt"></a> [libvirt](#requirement\_libvirt) | >=0.7.6 |
| <a name="requirement_remote"></a> [remote](#requirement\_remote) | 0.1.2 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_libvirt"></a> [libvirt](#provider\_libvirt) | >=0.7.6 |
| <a name="provider_local"></a> [local](#provider\_local) | n/a |
| <a name="provider_null"></a> [null](#provider\_null) | n/a |
| <a name="provider_remote"></a> [remote](#provider\_remote) | 0.1.2 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [libvirt_domain.ocp_masters](https://registry.terraform.io/providers/dmacvicar/libvirt/latest/docs/resources/domain) | resource |
| [libvirt_domain.ocp_workers](https://registry.terraform.io/providers/dmacvicar/libvirt/latest/docs/resources/domain) | resource |
| [libvirt_volume.ocp_masters](https://registry.terraform.io/providers/dmacvicar/libvirt/latest/docs/resources/volume) | resource |
| [libvirt_volume.ocp_masters_base](https://registry.terraform.io/providers/dmacvicar/libvirt/latest/docs/resources/volume) | resource |
| [libvirt_volume.ocp_workers](https://registry.terraform.io/providers/dmacvicar/libvirt/latest/docs/resources/volume) | resource |
| [libvirt_volume.ocp_workers_base](https://registry.terraform.io/providers/dmacvicar/libvirt/latest/docs/resources/volume) | resource |
| [local_file.aicli_ocp_config](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [local_file.ocp_kubeadmin_password](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [local_file.ocp_kubeconfig](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [null_resource.aicli_calico_setup](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.ocp_install](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.post_install_script](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [remote_file.ocp_kubeadmin_password](https://registry.terraform.io/providers/tenstad/remote/0.1.2/docs/data-sources/file) | data source |
| [remote_file.ocp_kubeconfig](https://registry.terraform.io/providers/tenstad/remote/0.1.2/docs/data-sources/file) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aicli_version"></a> [aicli\_version](#input\_aicli\_version) | aicli version | `string` | `"99.0.202403282009"` | no |
| <a name="input_calico_version"></a> [calico\_version](#input\_calico\_version) | calico version for the ocp | `string` | n/a | yes |
| <a name="input_kube_api_server_ip"></a> [kube\_api\_server\_ip](#input\_kube\_api\_server\_ip) | kube api server ip address, since we use the private FQDN, setting this will run post\_install\_script resource to override the /etct/hosts files | `string` | `""` | no |
| <a name="input_kvm_host_ip_address"></a> [kvm\_host\_ip\_address](#input\_kvm\_host\_ip\_address) | kvm host ip address for OCP VM deployment | `string` | n/a | yes |
| <a name="input_kvm_host_username"></a> [kvm\_host\_username](#input\_kvm\_host\_username) | kvm host username for OCP VM deployment | `string` | `"root"` | no |
| <a name="input_libvirt_private_network_id"></a> [libvirt\_private\_network\_id](#input\_libvirt\_private\_network\_id) | libvirt private network id | `any` | n/a | yes |
| <a name="input_libvirt_volume_main_name"></a> [libvirt\_volume\_main\_name](#input\_libvirt\_volume\_main\_name) | libvirt main pool name | `any` | n/a | yes |
| <a name="input_ocp_base_domain"></a> [ocp\_base\_domain](#input\_ocp\_base\_domain) | base domain name for ocp cluster | `string` | n/a | yes |
| <a name="input_ocp_cluster_name"></a> [ocp\_cluster\_name](#input\_ocp\_cluster\_name) | ocp cluster name | `string` | `"default-ocp-name"` | no |
| <a name="input_ocp_master_ip_mac_hostname_map"></a> [ocp\_master\_ip\_mac\_hostname\_map](#input\_ocp\_master\_ip\_mac\_hostname\_map) | master\_ip\_mac\_host\_map from terraform-equinix-infra module. If provided, it will get the static IP address and FQDN mapping predefined in terraform-equinix-infra's router | `string` | `""` | no |
| <a name="input_ocp_masters_count"></a> [ocp\_masters\_count](#input\_ocp\_masters\_count) | the number of the OCP master VM, 3 or 5 shoud be enough for most cases. | `number` | `3` | no |
| <a name="input_ocp_offline_token"></a> [ocp\_offline\_token](#input\_ocp\_offline\_token) | the assistant installer token gather an offline token at https://cloud.redhat.com/openshift/token | `string` | `""` | no |
| <a name="input_ocp_version"></a> [ocp\_version](#input\_ocp\_version) | openshift version | `string` | `4.14` | no |
| <a name="input_ocp_worker_ip_mac_hostname_map"></a> [ocp\_worker\_ip\_mac\_hostname\_map](#input\_ocp\_worker\_ip\_mac\_hostname\_map) | worker\_ip\_mac\_host\_map from terraform-equinix-infra module. If provided, it will get the static IP address and FQDN mapping predefined in terraform-equinix-infra's router | `string` | `""` | no |
| <a name="input_ocp_workers_count"></a> [ocp\_workers\_count](#input\_ocp\_workers\_count) | the number of the OCP worker VM. | `number` | `2` | no |
| <a name="input_path_to_kvm_host_login_ssh_key"></a> [path\_to\_kvm\_host\_login\_ssh\_key](#input\_path\_to\_kvm\_host\_login\_ssh\_key) | private ssh key to login the kvm host | `string` | n/a | yes |
| <a name="input_path_to_ocp_pull_secret"></a> [path\_to\_ocp\_pull\_secret](#input\_path\_to\_ocp\_pull\_secret) | the ocp pull secret, the pull secret should match your redhat account for the offline\_token. you can get it from here https://console.redhat.com/openshift/install/pull-secret | `string` | `""` | no |
| <a name="input_path_to_ocp_setup_private_key"></a> [path\_to\_ocp\_setup\_private\_key](#input\_path\_to\_ocp\_setup\_private\_key) | private key to setup the ocp cluster | `string` | n/a | yes |
| <a name="input_private_network_ipv4_cidr"></a> [private\_network\_ipv4\_cidr](#input\_private\_network\_ipv4\_cidr) | private VM networks where the OCP VM sit | `any` | n/a | yes |
| <a name="input_private_network_ipv6_cidr"></a> [private\_network\_ipv6\_cidr](#input\_private\_network\_ipv6\_cidr) | private VM ipv6 networks where the OCP VM sit | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ocp_path_to_kubeconfig_file"></a> [ocp\_path\_to\_kubeconfig\_file](#output\_ocp\_path\_to\_kubeconfig\_file) | ocp kubeconfig location to access the k8s api server |
<!-- END_TF_DOCS -->