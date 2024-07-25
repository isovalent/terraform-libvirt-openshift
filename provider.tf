provider "libvirt" {
  uri = "qemu+ssh://${var.kvm_host_username}@${var.kvm_host_ip_address}/system?sshauth=privkey&known_hosts_verify=ignore&keyfile=${var.path_to_kvm_host_login_ssh_key}"
}