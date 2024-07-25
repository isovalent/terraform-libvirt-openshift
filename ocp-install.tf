resource "null_resource" "ocp_install" {
  depends_on = [libvirt_domain.ocp_workers, libvirt_domain.ocp_masters]

  connection {
    host        = var.kvm_host_ip_address
    user        = var.kvm_host_username
    private_key = file(var.path_to_kvm_host_login_ssh_key)
    timeout     = "5m"
    type        = "ssh"
  }
  provisioner "file" {
    source      = "${path.module}/scripts/install-ocp.sh"
    destination = "/aicli/install-ocp.sh"
  }
  provisioner "remote-exec" {
    inline = [<<EOF
      set -o errexit
      chmod +x /aicli/install-ocp.sh;
      export OCP_OFFLINE_TOKEN="${var.ocp_offline_token}";
      export OCP_NODES_NUM="${var.ocp_masters_count + var.ocp_workers_count}";
      export OCP_CLUSTER_NAME="${var.ocp_cluster_name}";
      /aicli/install-ocp.sh;
    EOF
    ]
  }
}

