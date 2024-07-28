resource "local_file" "aicli_ocp_config" {
  content = templatefile("${path.module}/templates/aicli-ocp-config.yaml", {
    ocp_version                  = var.ocp_version
    ocp_base_domain              = var.ocp_base_domain
    vm_private_network_ipv4_cidr = var.private_network_ipv4_cidr
    vm_private_network_ipv6_cidr = var.private_network_ipv6_cidr
  })
  filename = "${path.module}/tmp/aicli-ocp-config-${var.ocp_cluster_name}.yaml"
}

resource "null_resource" "aicli_calico_setup" {
  depends_on = [local_file.aicli_ocp_config]

  connection {
    host        = var.kvm_host_ip_address
    user        = var.kvm_host_username
    private_key = file(var.path_to_kvm_host_login_ssh_key)
    timeout     = "5m"
    type        = "ssh"
  }

  provisioner "remote-exec" {
    inline = ["mkdir -p /aicli/ocp-manifests-dir",
    "chmod 777 -R /aicli"]
  }

  provisioner "file" {
    source      = var.path_to_ocp_setup_private_key
    destination = "/aicli/id_rsa"

  }
  provisioner "file" {
    source      = var.path_to_ocp_pull_secret
    destination = "/aicli/openshift_pull.json"
  }
  provisioner "file" {
    source      = "${path.module}/tmp/aicli-ocp-config-${var.ocp_cluster_name}.yaml"
    destination = "/aicli/aicli-ocp-config-${var.ocp_cluster_name}.yaml"

  }
  provisioner "file" {
    source      = "${path.module}/scripts/setup-aicli-calico.sh"
    destination = "/aicli/setup-aicli-calico.sh"
  }
  provisioner "remote-exec" {
    inline = [<<EOF
      set -o errexit
      chmod +x /aicli/setup-aicli-calico.sh;
      export OCP_OFFLINE_TOKEN="${var.ocp_offline_token}";
      export OCP_CLUSTER_NAME="${var.ocp_cluster_name}";
      export OCP_BASE_DOMAIN="${var.ocp_base_domain}";
      export AICLI_VERSION="${var.aicli_version}";
      export CALICO_VERSION="${var.calico_version}";
      /aicli/setup-aicli-calico.sh;
      sleep 1
    EOF
    ]
  }
}


