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

// The base root volume for the ocp_workers.

resource "libvirt_volume" "ocp_workers_base" {
  depends_on = [null_resource.aicli_cilium_setup]
  count      = var.ocp_workers_count
  name       = var.ocp_worker_ip_mac_hostname_map == "" ? "ocp-workers${count.index}-base" : "${var.ocp_worker_ip_mac_hostname_map[count.index][2]}-base"
  pool       = var.libvirt_volume_main_name
  size       = 150000000000

}
// The root volume for the ocp_workers.
resource "libvirt_volume" "ocp_workers" {
  count          = var.ocp_workers_count
  base_volume_id = libvirt_volume.ocp_workers_base[count.index].id
  format         = "qcow2"
  name           = var.ocp_worker_ip_mac_hostname_map == "" ? "ocp-workers${count.index}.qcow2" : "${var.ocp_worker_ip_mac_hostname_map[count.index][2]}.qcow2"
  pool           = var.libvirt_volume_main_name
}

// The ocp_workers VM.
resource "libvirt_domain" "ocp_workers" {
  count = var.ocp_workers_count
  cpu {
    mode = "host-passthrough"
  }

  autostart = true
  memory    = 8192
  name      = "ocp_workers-${count.index}"
  vcpu      = 2

  console {
    type        = "stdio"
    target_port = "0"
    target_type = "serial"
  }
  boot_device {
    dev = ["hd", "cdrom"]
  }
  disk {
    file = "/aicli/${var.ocp_cluster_name}.iso"
  }

  disk {
    volume_id = libvirt_volume.ocp_workers[count.index].id
  }

  graphics {
    listen_type    = "address"
    listen_address = "0.0.0.0"
  }
  network_interface {
    mac            = var.ocp_worker_ip_mac_hostname_map == "" ? null : "${var.ocp_worker_ip_mac_hostname_map[count.index][1]}"
    network_id     = var.libvirt_private_network_id
    wait_for_lease = false
  }
}
