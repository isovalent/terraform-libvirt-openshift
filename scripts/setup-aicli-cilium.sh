#!/bin/bash

set -euxo pipefail

# Silence is bliss.


# Get the operating system information
os_name=$(lsb_release -si)
os_version=$(lsb_release -sr)

# Check if the OS is Debian and version is 12
if [[ "$os_name" == "Debian" && "$os_version" == "12" ]]; then
  echo "This is Debian 12."
else
  echo "Error: This is not Debian 12."
  exit 1
fi


if command -v aicli > /dev/null 2>&1; then
    echo aicli is already installed.
else
    echo "aicli is not installed. Installing it now..."
    apt update
    # install aicli and pip for later to use 
    apt --yes install --no-install-recommends python3-pip
    pip3 install aicli==$AICLI_VERSION --break-system-packages
fi
# set up the public key for OCP to use
chmod 400 /aicli/id_rsa
ssh-keygen -y -f /aicli/id_rsa > /aicli/id_rsa.pub
cp -f /aicli/id_rsa.pub ~/.ssh/
# aicli to install the OCP and download the image
aicli --offlinetoken $OCP_OFFLINE_TOKEN delete cluster $OCP_CLUSTER_NAME -y || true
aicli --offlinetoken $OCP_OFFLINE_TOKEN create cluster $OCP_CLUSTER_NAME --pf /aicli/aicli-ocp-config-$OCP_CLUSTER_NAME.yaml 
aicli --offlinetoken $OCP_OFFLINE_TOKEN download iso $OCP_CLUSTER_NAME -p /aicli/
#install the cilium for OCP
curl -o /aicli/cilium-ee-$CILIUM_VERSION.tar.gz https://docs.isovalent.com/public/cilium-ee-olm/cilium-ee-$CILIUM_VERSION.tar.gz
tar -xvf /aicli/cilium-ee-$CILIUM_VERSION.tar.gz -C /aicli

rm -rf  /aicli/ocp-manifests-dir/*
cp /aicli/cilium.v$CILIUM_VERSION/* /aicli/ocp-manifests-dir 
#copy over the cilium config and override the default one
cp /aicli/cluster-network-07-cilium-ciliumconfig.yaml /aicli/ocp-manifests-dir
aicli create manifests --dir /aicli/ocp-manifests-dir $OCP_CLUSTER_NAME