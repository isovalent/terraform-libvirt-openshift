#!/bin/bash
set -euxo pipefail

ocp_installed_status=$(aicli info cluster $OCP_CLUSTER_NAME | grep -e '^status:.*$')

if [ "$ocp_installed_status" != "status: installed" ]; then
    echo "OCP has not been installed. Installing..."
    aicli --offlinetoken $OCP_OFFLINE_TOKEN wait hosts $OCP_CLUSTER_NAME -n $OCP_NODES_NUM
    aicli --offlinetoken $OCP_OFFLINE_TOKEN wait cluster $OCP_CLUSTER_NAME -s ready
    aicli --offlinetoken $OCP_OFFLINE_TOKEN start cluster $OCP_CLUSTER_NAME
    aicli --offlinetoken $OCP_OFFLINE_TOKEN wait cluster $OCP_CLUSTER_NAME
fi

echo "download the kubeconfig and kubeadm password"
aicli --offlinetoken $OCP_OFFLINE_TOKEN download kubeconfig $OCP_CLUSTER_NAME --path /aicli/
aicli  --offlinetoken $OCP_OFFLINE_TOKEN download kubeadmin-password $OCP_CLUSTER_NAME --path /aicli/
