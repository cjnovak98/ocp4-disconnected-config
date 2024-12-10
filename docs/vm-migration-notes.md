\pagebreak

# VM Migration from VMware vCenter to OpenShift Virtualization

This guide outlines the steps to migrate virtual machines (VMs) from VMware vCenter to OpenShift Virtualization. It includes setting up networking, managing VM configurations, executing the migration, and troubleshooting common issues.

1. EXPAND: migrate all target vms to singl esxi host <!-- - TODO: add steps and screenshots to Migrate all target vms to single esxi host  -->
1. EXPAND: remove esxi host from vcenter <!-- - TODO: add steps and screenshots to remove esxi host from vcenter -->
1. EXPAND: disable fast-boot and gracefully shut down windows vms <!-- - TODO: add steps and screenshots to disable fast-boot on windows vms -->
1. EXPAND: gracefully shut down remaining linux vms if necessary <!-- - TODO: add steps and screenshots to graceful shut down remaining vms --> 
1. Go to `{{OPENSHIFT_URL}}`
1. Click `{{LOGIN_BUTTON}}` to login <!-- TODO: Login Screenshot -->
1. Switch to Administrator perspective (if not already)
1. Click `Operators` in menu on left navigation
1. Click `Installed Operators` in sub-menu
1. Verify you see the following <!-- TODO: verify installed operators screenshot -->
    - Openshift Virtualization
    - Migration Toolkit for Virtualization
    - Kubernetes NMState
1. Click `Networking` in the left navigation menu
1. Click `Node Network Config Policies` <!-- TODO: Verify this button name -->
1. Verify you see the `bond0` object <!-- TODO: verify and add screenshot for verifying networking -->
1. Click `Migration` --> `Source Providers` in the left navigation menu
1. Ensure Project is set to `dcgs-vms` at the top <!-- TODO: Add screenshot for settng project -->
1. Click `Add Source Provider` <!-- TODO: Verify this button text and add screenshot -->
1. EXPAND: steps for adding esxi host provider <!-- TODO: expand steps and add screenshots for adding esxi host provider -->
1. Get user api token by clicking your username in the top right and then `Copy Login Command` <!-- TODO: add screenshot for copy login command -->
1. Click `{{LOGIN_BUTTON}}` to verify login <!-- TODO: screenshot for login buton -->
1. Click `Display Token` <!-- TODO: Add screenshot for display token -->
1. Copy the sha256~ token displayed <!-- TODO: screenshot for copying token -->
1. Click `Migration` --> `Source Providers` in the left navigation menu
1. Click `Add Source Provider` <!-- TODO: Verify this button text and add screenshot -->
1. EXPAND: steps for adding ocp-virt host provider <!-- TODO: expand steps and add screenshots for adding ocp-virt host provider -->
1. Ensure Project is set to `dcgs-vms` at the top <!-- TODO: Add screenshot for settng project -->
1. EXPAND: steps for modifying the `controller_max_vm_inflight` setting which is found in the forklift-controller CR created by the MTV operator. <!-- TODO: expand on modifying the max in flight setting and add screenshot -->
1. Click `Migration` --> `Migration Plans`
1. Click `Create Migration` <!-- TODO: add screenshot to create the migration plan -->
1. Select `esxi-host` source provider <!-- TODO: Screenshot for selecting source provider -->
1. Change the number of displayed results to 100 for easier selection process
1. Select vms intended to be migrated over <!-- TODO: Screenshot for selecting vms and clicking next -->
1. Specifiy networking maps by changing the default option to a vlan with the appropriate
1. Specify the storage map if needed. It should default to `basic-csi` which is acceptable <!-- TODO: screenshot for networking and storage mappings -->
1. Click Create Migration Plan
1. Wait for Migration Plan to be validated (this may take several minutes) <!-- TODO: Screenshot for what a validated migration plan should look like -->
1. Once ready, click `Start Migration` button and switch to vms tab to monitor progress <!-- TODO: screenshot for starting migration and progress screen -->
1. Once all VMs have been migrated, go back to syscon console

5 Troubleshooting and more information

6 Alternate migration method (manual ova copy instructions)
