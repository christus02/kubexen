# Creating a VM Template to be used with this tool

This section details how to create a VM template on a XenServer so that it can be used with this tool for provisioning the VMs automatically.

This guide also explains the steps required for assigning static IPs for the provisioned VMs. This is actually the main problem we are solving here. This is explained in the further sections and how we are solving it using bootstrap scripts.

If you choose to go with the DHCP mode of installation, then you need not worry about this.

## Steps:

### Create a VM in the Xenserver with required specification

Create a VM in the Xenserver using an ISO of the required linux distribution. You can choose the required CPU, Memory and Storage specs.

**Note** DO not configure any static IP if you choose to use this VM as a template for static IP installation mode.

### Install Citrix Xen tools in the VM

Once the VM is UP and running, install Citrix Xen Tools in this VM

### Add the BootStrap script to the VM

Upload or Copy the bootstrap script provided [here](../bootstrap-scripts/ubuntu/raghulc_configure_ip_address.bash) to the VM. Place it in `/var/` location.

Give execute permissions for the script

```
chmod +x /var/raghulc_configure_ip_address.bash
```

This script would configure Static IP address on the VM once we use this VM template to provision Kubernetes nodes in XenServer.

### Create a cronjob to run the bootstrap script on bootup

Create a CronJob to execute this bootstrap script when the VM starts

```
crontab -e
@reboot  /var/raghulc_configure_ip_address.bash
```

### Export this VM as a template

Now remove any IP configured in the VM and then export it to a Template. 

Note the name of the VM export. You can use this name in the section `vm.template` of the `../vars/config.yml` config file. Also provide the username and password of this VM export in `vm.template_username` and `vm.template_password` of `../vars/config.yml`
