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