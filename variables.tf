// Copyright 2023 Isovalent, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.


variable "ocp_cluster_name" {
  description = "ocp cluster name"
  type        = string
  default     = "default-ocp-name"
}

variable "ocp_base_domain" {
  description = "base domain name for ocp cluster"
  type        = string

}
variable "ocp_offline_token" {
  default     = ""
  description = "the assistant installer token gather an offline token at https://cloud.redhat.com/openshift/token"
  type        = string
}

variable "path_to_ocp_pull_secret" {
  default     = ""
  description = "the ocp pull secret, the pull secret should match your redhat account for the offline_token. you can get it from here https://console.redhat.com/openshift/install/pull-secret"
  type        = string
}

variable "ocp_masters_count" {
  description = "the number of the OCP master VM, 3 or 5 shoud be enough for most cases."
  type        = number
  default     = 3
}

variable "ocp_workers_count" {
  description = "the number of the OCP worker VM."
  type        = number
  default     = 2
}

variable "ocp_version" {
  description = "openshift version"
  type        = string
  default     = 4.14
}

variable "aicli_version" {
  description = "aicli version"
  default     = "99.0.202403282009"
  type        = string
}

variable "kvm_host_ip_address" {
  description = "kvm host ip address for OCP VM deployment"
  type        = string
}

variable "kvm_host_username" {
  description = "kvm host username for OCP VM deployment"
  type        = string
  default     = "root"

}

variable "path_to_kvm_host_login_ssh_key" {
  description = "private ssh key to login the kvm host"
  type        = string

}


variable "path_to_ocp_setup_private_key" {
  description = "private key to setup the ocp cluster"
  type        = string

}



variable "calico_version" {
  description = "calico version for the ocp"
  type        = string


}

variable "ocp_master_ip_mac_hostname_map" {
  description = "master_ip_mac_host_map from terraform-equinix-infra module. If provided, it will get the static IP address and FQDN mapping predefined in terraform-equinix-infra's router"
  default     = ""
}

variable "ocp_worker_ip_mac_hostname_map" {
  description = "worker_ip_mac_host_map from terraform-equinix-infra module. If provided, it will get the static IP address and FQDN mapping predefined in terraform-equinix-infra's router"
  default     = ""

}

variable "libvirt_volume_main_name" {
  description = "libvirt main pool name"

}

variable "libvirt_private_network_id" {
  description = "libvirt private network id"

}

variable "private_network_ipv4_cidr" {
  description = "private VM networks where the OCP VM sit"

}

variable "private_network_ipv6_cidr" {
  description = "private VM ipv6 networks where the OCP VM sit"
  default     = ""
}

variable "kube_api_server_ip" {
  description = "kube api server ip address, since we use the private FQDN, setting this will run post_install_script resource to override the /etct/hosts files"
  default     = ""

}