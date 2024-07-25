data "remote_file" "ocp_kubeconfig" {
  depends_on = [
    null_resource.ocp_install,
  ]

  conn {
    host        = var.kvm_host_ip_address
    user        = var.kvm_host_username
    private_key = file(var.path_to_kvm_host_login_ssh_key)
  }

  path = "/aicli/kubeconfig.${var.ocp_cluster_name}"
}


data "remote_file" "ocp_kubeadmin_password" {
  depends_on = [
    null_resource.ocp_install,
  ]

  conn {
    host        = var.kvm_host_ip_address
    user        = var.kvm_host_username
    private_key = file(var.path_to_kvm_host_login_ssh_key)
  }

  path = "/aicli/kubeadmin-password.${var.ocp_cluster_name}"
}



resource "local_file" "ocp_kubeconfig" {
  content  = data.remote_file.ocp_kubeconfig.content
  filename = "${path.module}/output/ocp-kubeconfig"
}


resource "local_file" "ocp_kubeadmin_password" {
  content  = data.remote_file.ocp_kubeadmin_password.content
  filename = "${abspath(path.module)}/output/ocp-kubeadmin-password"
}

output "ocp_path_to_kubeconfig_file" {
  description = "ocp kubeconfig location to access the k8s api server"
  value = local_file.ocp_kubeconfig.filename

}

resource "null_resource" "post_install_script" {
  count      = var.kube_api_server_ip != "" ? 1 : 0
  depends_on = [local_file.ocp_kubeconfig]
  provisioner "local-exec" {
    command = <<-EOT
          sudo sed -i "/$API_FQDN/d" /etc/hosts;
          sudo sed -i "/$CONSOLE_FQDN/d" /etc/hosts;
          sudo sed -i "/$AUTH_FQDN/d" /etc/hosts;
          echo $IP $API_FQDN | sudo tee -a /etc/hosts;
          echo $IP $CONSOLE_FQDN | sudo tee -a /etc/hosts;
          echo $IP $AUTH_FQDN | sudo tee -a /etc/hosts;
EOT 
    environment = {
      API_FQDN     = "api.${var.ocp_cluster_name}.${var.ocp_base_domain}"
      CONSOLE_FQDN = "console-openshift-console.apps.${var.ocp_cluster_name}.${var.ocp_base_domain}"
      AUTH_FQDN    = "oauth-openshift.apps.${var.ocp_cluster_name}.${var.ocp_base_domain}"
      IP           = var.kube_api_server_ip
    }
  }

}