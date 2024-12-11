\pagebreak

# VM Migration from VMware vCenter to OpenShift Virtualization

This guide outlines the steps to migrate virtual machines (VMs) from VMware vCenter to OpenShift Virtualization. It includes setting up networking, managing VM configurations, executing the migration, and troubleshooting common issues.

> First prepare the ESXi/vSphere enviornment

1. EXPAND: migrate all target vms to singl esxi host <!-- - TODO: add steps and screenshots to Migrate all target vms to single esxi host  -->
1. EXPAND: remove esxi host from vcenter <!-- - TODO: add steps and screenshots to remove esxi host from vcenter -->
1. EXPAND: disable fast-boot and gracefully shut down windows vms <!-- - TODO: add steps and screenshots to disable fast-boot on windows vms -->
1. EXPAND: gracefully shut down remaining linux vms if necessary <!-- - TODO: add steps and screenshots to graceful shut down remaining vms -->
1. Go to `{{OPENSHIFT_URL}}`
1. Click `{{LOGIN_BUTTON}}` to login
    ![](/docs/images/screenshots/getAPIToken2.PNG "OCP Login screen")
1. Switch to Administrator perspective (if not already)
1. Click `Operators` in menu on left navigation
1. Click `Installed Operators` in sub-menu
1. Verify you see the following
    - Openshift Virtualization
    - Migration Toolkit for Virtualization
    - Kubernetes NMState
    ![](/docs/images/screenshots/verifyOperators.PNG "OCP Login screen")
1. Click `Networking` in the left navigation menu
1. Click `NodeNetworkConfigurationPolicy`
1. Verify you see the `bond0` object <!-- TODO: verify and add screenshot for verifying networking -->
1. Click `Migration` --> `Providers for virtualization` in the left navigation menu
1. Ensure Project is set to `dcgs-vms` at the top <!-- TODO: Add screenshot for settng project -->
1. Click `Create Provider` <!-- TODO: add screenshot -->
1. Click `VM vSphere` option under `Provider details`
1. Type `esxi-host` for the `Provider resource name` field (all lowercase and no spaces)
1. Change the `Endpoint type` from vCenter to `ESXi`
1. Type in the `URL` (i.e. https://1.1.1.1/sdk)
1. Type in `{{SYSCON_IP_ADDR}}/dcgs/vddk:2` for the `VDDK init image` path field
1. Type in the ESXi username for `Username`
1. Type in the ESXi password for the `Password`
1. Click the `Skip certificate validation` radio button
1. Click the blue `Create provider` button <!-- TODO: add screenshot -->
1. Get user api token by clicking your username in the top right and then `Copy Login Command` <!-- TODO: add screenshot for copy login command -->
1. Click `{{LOGIN_BUTTON}}` to verify login <!-- TODO: screenshot for login buton -->
1. Click `Display Token` <!-- TODO: Add screenshot for display token -->
1. Copy the sha256~ token displayed <!-- TODO: screenshot for copying token -->
1. Click `Migration` --> `Providers for virtualization` in the left navigation menu. NOTE: This is a second provider being added, so some steps will be a repeat from earlier.
1. Ensure Project is set to `dcgs-vms` at the top <!-- TODO: Add screenshot for settng project -->
1. Click `Create Provider` <!-- TODO: add screenshot -->
1. Select `Openshift Virtualization` for the provider type
1. Type `ocpvirt` for the `Provider resource name`
1. Type `{{OPENSHIFT_CLUSTER_API_URL}}` for the URL
1. Paste in your sha256~ token value that you copied earlier into the `Service account bearer token` field
1. Click the `Skip certificate validation` radio button
1. Click `Create Provider` <!-- TODO: add screenshot -->
1. Click `Operators` --> `Installed Operators` in the left navigation menu
1. Ensure project is set to `All Projects` at the top
1. Select the `Migration Toolkit for Virtualization Operator` option <!-- TODO: add screenshot -->
1. Switch to the `ForkliftController` tab
1. Select the `FC forklift-controller` resource <!-- TODO: add screenshot -->
1. Switch to the `YAML` tab at the top and wait for it to load (text will colorize once resource is loaded)
1. Type `controller_max_vm_inflight: 5` immediately following the `spec:` line. (ensure proper spacing allignment) 
1. Click `Save` <!-- TODO: add screenshot -->
1. Click `Migration` --> `Plans for virtualization` in the left navigation menu
1. Ensure project is set to `dcgs-vms` at the top
1. Click `Create Plan` <!-- TODO: add screenshot to create the migration plan -->
1. Select `esxi-host` source provider <!-- TODO: Screenshot for selecting source provider -->
1. Once the list of available VMs is loaded, change the number of displayed results to 100 for easier selection process <!-- TODO: add screenshot -->
1. Select vms intended to be migrated over 
1. Click `Next` <!-- TODO: add screenshot -->
1. Type `dcgs-vm-migration-initial` for the `Plan name` field. (all lowercase and no spaces)
1. Verify the number of `Selected VMs` is what you expect
1. Select `ocpvirt` for the `Target provider`
1. Ensure `dcgs-vms` is selected for `Target namespace`
1. Complete the network mappings by matching the appropriate vlan ids
1. Verify storage map is set to `basic-csi` on the right. 
1. Click `Create migration plan` <!-- TODO: add screenshot -->
1. Wait for Migration Plan to be validated (you can expect to see a Warning flag and this validation may take several minutes before the next button is available) <!-- TODO: Screenshot for what a validated migration plan should look like -->
1. Once validation is complete, click `Start Migration` button. <!-- TODO: add screenshot -->
1. Once the migration has started the page should display some progress bars <!-- TODO: add screenshot -->
1. Switch to `Virtual Machines` tab to monitor progress <!-- TODO: screenshot for starting migration and progress screen -->
1. Once all VMs have been migrated, go back to syscon console
1. Change directory to the config repo if not already there (i.e. /opt/syscon/ocp4-disconnected-config)
1. Run command `./scripts/update-drivers.sh`
1. Go back to the Openshift Console in the browser window
1. Select `Virtualization` --> `VirtualMachines` in the left navigation menu
1. Ensure the project is set to `dcgs-vms` at the top
1. You should see a list of your migrated virtual machines on this screen and be able to click on them to manage them.

5 Troubleshooting and more information

6 Alternate migration method (manual ova copy instructions)
