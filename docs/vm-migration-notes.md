\pagebreak

# VM Migration from VMware vCenter to OpenShift Virtualization

This guide outlines the steps to migrate virtual machines (VMs) from VMware vCenter to OpenShift Virtualization. It includes setting up networking, managing VM configurations, executing the migration, and troubleshooting common issues.

## Prepare ESXi/vSphere environment

(@) EXPAND: migrate all target vms to singl esxi host <!-- - TODO: add steps and screenshots to Migrate all target vms to single esxi host  -->
(@) EXPAND: remove esxi host from vcenter <!-- - TODO: add steps and screenshots to remove esxi host from vcenter -->
(@) EXPAND: disable fast-boot and gracefully shut down windows vms <!-- - TODO: add steps and screenshots to disable fast-boot on windows vms -->
(@) EXPAND: gracefully shut down remaining linux vms if necessary <!-- - TODO: add steps and screenshots to graceful shut down remaining vms -->

## Prepare Openshift Virtualization environment

(@) Go to `{{OPENSHIFT_URL}}`
(@) Click `{{LOGIN_BUTTON}}` to login

![](docs/images/screenshots/getAPIToken2.PNG "OCP Login screen")

(@) Switch to Administrator perspective (if not already)
(@) Click `Operators` in menu on left navigation
(@) Click `Installed Operators` in sub-menu
(@) Verify you see the following
    - Openshift Virtualization
    - Migration Toolkit for Virtualization
    - Kubernetes NMState

![](docs/images/screenshots/verifyOperators.PNG "OCP Login screen")

(@) Click `Networking` in the left navigation menu
(@) Click `NodeNetworkConfigurationPolicy`
(@) Verify you see the `bond0` object <!-- TODO: verify and add screenshot for verifying networking -->
(@) Click `Migration` --> `Providers for virtualization` in the left navigation menu
(@) Ensure Project is set to `dcgs-vms` at the top
(@) Click `Create Provider` <!-- TODO: add screenshot -->
(@) Click `VM vSphere` option under `Provider details`
(@) Type `esxi-host` for the `Provider resource name` field (all lowercase and no spaces)
(@) Change the `Endpoint type` from vCenter to `ESXi`
(@) Type in the `URL` (i.e. https://1.1.1.1/sdk)
(@) Type in `{{SYSCON_IP_ADDR}}/dcgs/vddk:2` for the `VDDK init image` path field
(@) Type in the ESXi username for `Username`
(@) Type in the ESXi password for the `Password`
(@) Click the `Skip certificate validation` radio button
(@) Click the blue `Create provider` button <!-- TODO: add screenshot -->
(@) Get user api token by clicking your username in the top right and then `Copy Login Command` <!-- TODO: add screenshot for copy login command -->
(@) Click `{{LOGIN_BUTTON}}` to verify login <!-- TODO: screenshot for login buton -->
(@) Click `Display Token` <!-- TODO: Add screenshot for display token -->
(@) Copy the sha256~ token displayed <!-- TODO: screenshot for copying token -->
(@) Click `Migration` --> `Providers for virtualization` in the left navigation menu. NOTE: This is a second provider being added, so some steps will be a repeat from earlier.
(@) Ensure Project is set to `dcgs-vms` at the top <!-- TODO: Add screenshot for settng project -->
(@) Click `Create Provider` <!-- TODO: add screenshot -->
(@) Select `Openshift Virtualization` for the provider type
(@) Type `ocpvirt` for the `Provider resource name`
(@) Type `{{OPENSHIFT_CLUSTER_API_URL}}` for the URL
(@) Paste in your sha256~ token value that you copied earlier into the `Service account bearer token` field
(@) Click the `Skip certificate validation` radio button
(@) Click `Create Provider` <!-- TODO: add screenshot -->
(@) Click `Operators` --> `Installed Operators` in the left navigation menu
(@) Ensure project is set to `All Projects` at the top
(@) Select the `Migration Toolkit for Virtualization Operator` option <!-- TODO: add screenshot -->
(@) Switch to the `ForkliftController` tab
(@) Select the `FC forklift-controller` resource <!-- TODO: add screenshot -->
(@) Switch to the `YAML` tab at the top and wait for it to load (text will colorize once resource is loaded)
(@) Type `controller_max_vm_inflight: 5` immediately following the `spec:` line. (ensure proper spacing allignment) 
(@) Click `Save` <!-- TODO: add screenshot -->
(@) Click `Migration` --> `Plans for virtualization` in the left navigation menu
(@) Ensure project is set to `dcgs-vms` at the top
(@) Click `Create Plan` <!-- TODO: add screenshot to create the migration plan -->
(@) Select `esxi-host` source provider <!-- TODO: Screenshot for selecting source provider -->
(@) Once the list of available VMs is loaded, change the number of displayed results to 100 for easier selection process <!-- TODO: add screenshot -->
(@) Select vms intended to be migrated over 
(@) Click `Next` <!-- TODO: add screenshot -->
(@) Type `dcgs-vm-migration-initial` for the `Plan name` field. (all lowercase and no spaces)
(@) Verify the number of `Selected VMs` is what you expect
(@) Select `ocpvirt` for the `Target provider`
(@) Ensure `dcgs-vms` is selected for `Target namespace`
(@) Complete the network mappings by matching the appropriate vlan ids
(@) Verify storage map is set to `basic-csi` on the right. 
(@) Click `Create migration plan` <!-- TODO: add screenshot -->
(@) Wait for Migration Plan to be validated (you can expect to see a Warning flag and this validation may take several minutes before the next button is available) <!-- TODO: Screenshot for what a validated migration plan should look like -->
(@) Once validation is complete, click `Start Migration` button. <!-- TODO: add screenshot -->
(@) Once the migration has started the page should display some progress bars <!-- TODO: add screenshot -->
(@) Switch to `Virtual Machines` tab to monitor progress <!-- TODO: screenshot for starting migration and progress screen -->
(@) Once all VMs have been migrated, go back to syscon console
(@) Change directory to the config repo if not already there (i.e. /opt/syscon/ocp4-disconnected-config)
(@) Run command `./scripts/update-drivers.sh`
(@) Go back to the Openshift Console in the browser window
(@) Select `Virtualization` --> `VirtualMachines` in the left navigation menu
(@) Ensure the project is set to `dcgs-vms` at the top
(@) You should see a list of your migrated virtual machines on this screen and be able to click on them to manage them.

5 Troubleshooting and more information

6 Alternate migration method (manual ova copy instructions)
