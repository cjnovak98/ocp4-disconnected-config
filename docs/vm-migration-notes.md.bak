\pagebreak

# VM Migration from VMware vCenter to OpenShift Virtualization

This guide outlines the steps to migrate virtual machines (VMs) from VMware vCenter to OpenShift Virtualization. It includes setting up networking, managing VM configurations, executing the migration, and troubleshooting common issues.

## Pre-Migration Preparation


### 1. Access and Permissions

* Ensure you have the necessary access permissions to both VMware vCenter and OpenShift Virtualization clusters.
* Create source provider(s) for vmware and/or vcenter:
	* Steps for creating a provider can be found here: [https://docs.redhat.com/en/documentation/migration_toolkit_for_virtualization/2.7/html-single/installing_and_using_the_migration_toolkit_for_virtualization/index#mtv-overview-page_mtv](https://docs.redhat.com/en/documentation/migration_toolkit_for_virtualization/2.7/html-single/installing_and_using_the_migration_toolkit_for_virtualization/index#mtv-overview-page_mtv)
* Verify the following operators are properly configured in OpenShift:
	* Virtualization Operator
		* for hosting the migrated virtual machines
	* Migration Toolkit for Virtualization Operator
		* to support a more automated migration of virtual machines off of VMware
	* Kubernetes NMState Operator
		* to manage the required networking configurations for the machines

### 2. Identify/Prepare Target VMs

Ensure the VM(s) you wish to migrate are properly identified in VMware. 

> WARNING: These VMs will need to be powered down for the migration and remain down for testing to avoid IP conflicts.

### 3. Networking Setup

* Create Bond: Create the Bond network using a Node Network Configuration Policy (NNCP). Example:

```yaml
apiVersion: nmstate.io/v1
kind: NodeNetworkConfigurationPolicy
metadata:
name: bond0
spec:
desiredState:
    interfaces:
    - name: bond0
        type: bond
        link-aggregation:
        mode: 802.3ad
        port:
            - ens2f0
            - ens2f1
            - ens3f0
            - ens3f1
```

* Create VLANs: Create VLANs to map network traffic between VMware and OpenShift Virtualization. 
    * Example VLAN IDs: `677` (primary), `58` (for public networks), 59 (for public networks).
[Example NodeNetworkConfigurationPolicy](https://github.com/cjnovak98/ocp4-disconnected-config/blob/main/Examples/node_network_config_policy.yaml)

* Network Attachment: Apply network attachment definitions (NAD) that point to the appropriate VLAN. For instance, the primary network for the migrated VMs will map to VLAN 677, while public-facing VMs might use VLAN 58.
  
> NOTE: Unless communication is needed with the containers then it is recommended to set the container network as disabled in the network attachment definition.
```yaml
---
#Example Network Attachment Definitions

apiVersion: "k8s.cni.cncf.io/v1"
kind: NetworkAttachmentDefinition
metadata:
  name: bond0-bridge-vlan677 
spec:
  config: '{
    "cniVersion": "0.3.1",
    "name": "bond0-bridge-vlan677", 
    "type": "bridge", 
    "bridge": "bond0-br0", 
    "macspoofchk": false, 
    "vlan": 677
  }'

---
apiVersion: "k8s.cni.cncf.io/v1"
kind: NetworkAttachmentDefinition
metadata:
  name: bond0-bridge-vlan58 
spec:
  config: '{
    "cniVersion": "0.3.1",
    "name": "bond0-bridge-vlan58", 
    "type": "bridge", 
    "bridge": "bond0-br0", 
    "macspoofchk": false, 
    "vlan": 58
  }'
```



## Migration Process


### Plan Setup

Migration plans are created in OpenShift using the Migration Toolkit. This plan selects the targeted virtual machines and specifies the source and destination environments.

* Choose Source Provider: Depending on your requirements, you can select the following:
    * ESXi Host (preferred): Directly migrate VMs from an ESXi host without going through vCenter. If you have access to the ESXi host directly this is the preferable source as it is faster and can handle more machines simultaneously. The limitation here is all of your specified VMs will need to be put onto this specific ESXi host in vCenter first or you will need to create a separate migration plan for each source ESXi host.
    * vCenter: Migrate from the full vCenter environment, but avoid pulling too many VMs simultaneously to prevent system crashes. When using this plan you will want to limit the plan to a single VM.

* Create Migration Plan:
	* Select source provider (e.g., `esxi13-2` or `vcenter`).
	* Enter a plan name using Kubernetes naming conventions:
		* name must be unique among other migration plans
		* at most 63 characters
		* only lowercase alphanumeric characters or '-'
		* start with alpha
		* end with alphanumeric
		* (e.g., `core-test-24oct-1449`).
	* Choose target provider: OpenShift Virtualization.
	* Set up network mapping:
        * Map VMware networks to OpenShift VLANs (e.g., map vlan-677 to vlan-677 in OCP).
	        * NOTE: if the source vlan numbers don't line up, vlan-677 is to be used for all internal communications and should likely be used by default. vlan 58 or 59 are considered the 'public' communication network.
	        * If the target vlan is not available then review the network attachment definitions are set up properly.
    * Set up storage mapping:
        * Select OpenShift's temporary storage (e.g., openshift-temp) and map it to OpenShift's CSI storage (e.g., basic-csi).

* Start Migration: Click Start Migration to initiate the migration of selected VMs.

### VM Post-Migration Configuration

The virtio drivers that OpenShift Virtualization uses are not supported by default for the older versions of RHEL and Windows Server. Since OpenShift Virtualization defaults to virtio for the network and disk interfaces you will need to update that setting post migration. Once the migration process is complete, and the VM is created in OpenShift (e.g., web-qa), follow these steps:

* Modify Network Interfaces:
    * Ensure the network interfaces are set to e1000e.
    * Be sure it is set to attach the VM to the correct VLAN (e.g., vlan-677 for internal network communication).
* Modify Disk Configuration:
    * Change the disk interface type from virtio to SATA 
* Start the VM:
    * Once all configurations are verified, go to Actions → Start to power on the VM in OpenShift Virtualization.
    * If the VM is already running you must stop it and restart it in order for the changes to be applied.

### Dealing with Windows-Specific Issues

For any Windows based VMs (e.g., Windows Server 2012), special steps are needed:

* Shutdown Windows Properly in vCenter:
  * Always shut down the Windows VM gracefully: `shutdown /s`.
  * Windows VMs can experience issues migrating due to hibernation or fast boot settings. When these are enabled it may cause the file system to be mounted as read-only which prevents the migration from taking place. 
  
  > NOTE: it appears fast boot is enabled by default for Windows Server 2012

## Recommended Practices and Considerations

### VMs Not Starting After Migration

Any VMs running an OS which is not in the list of supported guest operating systems, or operating systems that have difficulty with the virtio drivers may need to use these other drivers for their disk and network interfaces:

* Disk Configuration: Ensure all disks are configured to SATA after migration.

* Network Configuration: Double-check that the VM is connected to the correct VLAN and that e1000e is used for network interfaces. Additionally, if e1000e is the interface used in the VMware environment, then using this setting may help to ensure previous network configurations remain on the migrated VM.

### Migration Plan Recommended Practices

* Avoid migrating multiple VMs simultaneously from vCenter as this may overwhelm the system. Always perform migration of one VM at a time when migrating from vCenter as the source provider.

* It is also possible to throttle the number of simultaneous migrations in the MTV configurations. This will allow you to put more than one machine in a single migration plan (regardless of if it's from vCenter vs ESXi host) and not to overwhelm the source system. This can be done by modifying the `controller_max_vm_inflight` setting which is found in the forklift-controller CR created by the MTV operator. [More info for additional configuration options](https://docs.redhat.com/en/documentation/migration_toolkit_for_virtualization/2.7/html-single/installing_and_using_the_migration_toolkit_for_virtualization/index#configuring-mtv-operator_mtv)

```yaml
spec:
  controller_max_vm_inflight: <number> #defaults to 20
```

### Saving and Re-Importing VMs

* Consider creating backups of VM data and configurations before migration, especially when dealing with production VMs.

* Use tools like `virtctl` to upload images or configure persistent volumes. In case of failure, ensure you have a repeatable process for re-importing the VM images.

### Migration Plan Failures

* API Gateway Errors: If the migration fails due to a bad API gateway, verify network connectivity and access permissions for the gateway. Restarting the gateway or re-initiating the plan may resolve the issue.

* High RAM Usage: Monitor node resource usage during the migration process. Nodes with high memory consumption may affect the migration speed or cause failures.

### More information:
* More detailed information can be found in the migration toolkit user guide: [https://docs.redhat.com/en/documentation/migration_toolkit_for_virtualization/2.7](https://docs.redhat.com/en/documentation/migration_toolkit_for_virtualization/2.7)

* More detailed information about OpenShift Virtualization in general can be found here: [https://docs.redhat.com/en/documentation/openshift_container_platform/4.17/html/virtualization/index](https://docs.redhat.com/en/documentation/openshift_container_platform/4.17/html/virtualization/index)


## Automation Notes

<!-- TODO: update example with JT's script for this step -->

Automatically update the disk and network interfaces for all virtual machines with a script. This script:

* gets the current configurations for all vms on openshift and then loops through each to
  * modify the storage and network interfaces to use SATA/e1000e to prevent any potential virtio/storage issues for unsupported guest operating systems
  * apply the updated config
  * start or restart the VM

```bash
!#/bin/bash

# Set namespace and project
NAMESPACE="your-namespace"

# Get all VirtualMachine configurations from OpenShift
echo "Fetching all VM configurations..."
oc get vm -n "$NAMESPACE" -o name | while read -r vm; do
    echo "Processing $vm..."

    # Export the VM's YAML config
    oc get "$vm" -n "$NAMESPACE" -o yaml > "/tmp/${vm//\//-}.yaml"

    # Check if the YAML file exists
    if [[ ! -f "/tmp/${vm//\//-}.yaml" ]]; then
        echo "Error: Could not fetch YAML for $vm. Skipping..."
        continue
    fi

    # Perform sed replacement on disk interface type (virtio -> sata)
    echo "Updating disk interface to 'sata'"
    sed -i '/disk:/,/interface:/s/virtio/sata/g' "/tmp/${vm//\//-}.yaml"

    # Perform sed replacement on network interface type (virtio -> e1000e)
    echo "Updating network interface to 'e1000e'"
    sed -i '/networkInterfaces:/,/model:/s/virtio/e1000e/g' "/tmp/${vm//\//-}.yaml"

    # Apply the updated YAML to OpenShift
    echo "Applying updated configuration for $vm..."
    oc apply -f "/tmp/${vm//\//-}.yaml" -n "$NAMESPACE"

    # Check if the VM is running or stopped 
    vm_status=$(virtctl status "$vm" -n "$NAMESPACE" | grep -oP "(?<=Status: )\w+") 
    
    if [[ "$vm_status" == "Running" ]];
        echo "VM $vm is running. Stopping now..." 
        virtctl stop "$vm" 
    elif [[ "$vm_status" == "Stopped" ]];
        echo "VM $vm is already stopped." 
    else 
        echo "VM $vm is in an unknown state: $vm_status. Skipping restart..." 
        continue 
    fi

    # Start the VM 
    virtctl start "$vm"

    # Clean up the temporary file
    rm -f "/tmp/${vm//\//-}.yaml"

    echo "Finished processing $vm."
done

echo "All VM configurations updated successfully!"

```
