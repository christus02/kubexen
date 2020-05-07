# Provision a Kubernetes Cluster on Citrix XenServer

You can now provision a Kubernetes cluster on a [Citrix Xenserver](https://www.citrix.com/en-in/products/citrix-hypervisor/) using this tool. You can also specify the required CNI, node count and Kubernetes version.
This is an Ansible based tool that used [KubeADM](https://github.com/kubernetes/kubeadm) to bring up the Kubernetes Cluster.

This tool would create the Nodes in the XenServer for you and then install Kubernetes on them based on the parameters which you specify.

#### Pre-requisites:

1. Required Packages

```
apt install python-pip
pip install ansible
pip install XenAPI
apt install sshpass
export ANSIBLE_HOST_KEY_CHECKING=False
```
2. VM Template needs to be created. This is a one time process. This step can be skipped, if you choose not to provision nodes.

A detailed guide on how to create a VM export is given [here](docs/Create_VM_Template.md)

** Note ** Support for installing nodes from pre-built VM templates is work-in-progress.

## Let the tool know your requirements for creating the Kubernetes cluster

#### Clone this repository and modify the `vars/config.yml` file according to your needs

```
https://github.com/christus02/kubexen.git
cd kubexen
```

#### Edit the vars/config.yml file. Below are some of the parameters to be changed.

Specify the Xen Server details in the below section
```
xenserver:
  hostname: <IP/Hostname of the XenServer>
  username: <Username of the XenServer>
  password: <Password of the XenServer>
```

Provide the Free IPs in the XenServer management range. The Kubernetes nodes would be assigned these IPs after bring up.

The IPs should be specified as CIDR.

**The First IP would be assigned to the Master Node**
```
ip_config:
  ip:
  # Specify the IPs to be assigned for the nodes as CIDR (IP/PREFIX)
  - 10.0.0.11/24 # The first IP would be considered as Master
  - 10.0.0.12/24 # Worker Node 1
  - 10.0.0.13/24 # Worker Node 2
  gateway: 10.0.0.1
```

#### Choosing CNI:

You can provide the CNI to be installed in the below section.

```
cluster_configs:
  # Possible CNI list:
  # TODO
  cni: 'flannel'
```

#### Choosing the Kubernetes Version:

You can provide the Kubernetes Version to be installed in the below section.

```
cluster_configs:
  # Specify the Kubernetes version you wish to install
  version: '1.18.0'
```

Save the `vars/config.yml` file and exit.

## Create the Kubernetes Cluster

Now that you have updated the `vars/config.yml` file, run the Ansible playbook to provision VMs and create Kubernetes cluster

```
ansible-playbook kubexen.yml
```

Let the playbook run and in few more minutes your cluster would be UP and RUNNING.

## Logging in to the Kubernetes Master

Login to the Master IP provided in the `vars/config.yml` with the `vm.template_username` and `vm.template_password` specified in the `vars/config.yml` file

After logging in, you can execute the usual `kubectl` commands. 

Your Kubernetes cluster is now UP and READY.

## Delete a Kubernetes Cluster

Make sure the `vars/config.yml` is not changed and execute the below command to delete the created Kubernetes cluster

```
ansible-playbook kubexen.yml -t delete
```

The Kubernetes cluster can also be deleted by manually deleting the VMs from the XenCenter.

### DNS Resolution

All the nodes in the Kubernetes cluster can reach each other using the hostnames. This is made possible as the hostnames are configured as `xip.io` domain names. 

## Work-In-Progress:

1. Support all possible CNI
2. Option to bring up just Kubernetes without provisioning VMs
3. Make this tool Docker Ready
4. Support for importing a VM template from URL
