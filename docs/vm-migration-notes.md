\pagebreak

# VM Migration from VMware vCenter to OpenShift Virtualization

This guide outlines the steps to migrate virtual machines (VMs) from VMware vCenter to OpenShift Virtualization. It includes setting up networking, managing VM configurations, executing the migration, and troubleshooting common issues.

## Step 1: Prepare ESXi/vSphere environment

1.1 EXPAND: migrate all target vms to single esxi host <!-- - TODO: add steps and screenshots to Migrate all target vms to single esxi host  -->

1.2 EXPAND: remove esxi host from vcenter <!-- - TODO: add steps and screenshots to remove esxi host from vcenter -->

1.3 EXPAND: disable fast-boot and gracefully shut down windows vms <!-- - TODO: add steps and screenshots to disable fast-boot on windows vms -->

1.4 EXPAND: gracefully shut down remaining linux vms if necessary <!-- - TODO: add steps and screenshots to graceful shut down remaining vms -->

## Step 2: Prepare OpenShift Virtualization environment

### First we login to the OpenShift console in the web browser.

2.1 Go to `{{OPENSHIFT_URL}}`

2.2 Click `{{LOGIN_BUTTON}}` to login

![](docs/images/screenshots/getAPIToken2.PNG "OCP Login screen")

### In the next few steps we are making sure the automation successfully installed some critical components

2.3 Switch to Administrator perspective (if not already)

2.4 Click `Operators` in menu on left navigation

2.5 Click `Installed Operators` in sub-menu

2.6 Ensure project is set to `All Projects` at the top

2.7 Verify you see the following
    - Openshift Virtualization
    - Migration Toolkit for Virtualization
    - Kubernetes NMState

![](docs/images/screenshots/verifyOperators.PNG "verify operators screen")

2.8 Click `Networking` in the left navigation menu

2.9 Click `NodeNetworkConfigurationPolicy`

2.10 Verify you see the following objects: <!-- TODO: verify and add screenshot for verifying networking -->
  - bond0
  - etc <!-- TODO: verify which objects are needed -->

### Now we will configure the `Migration Toolkit` operator so that it can see the source host where the vms will be migrated from

> Note: you will need the username and login for the ESXi host

2.11 Click `Migration` --> `Providers for virtualization` in the left navigation menu

2.12 Ensure Project is set to `{{PROJECT_NAME}}` at the top

2.13 Click `Create Provider`

![](docs/images/screenshots/createSourceProvider.PNG "create source provider")

2.14 Select `VM vSphere` option under `Provider details`

![](docs/images/screenshots/createSourceProvider2.PNG "create source provider")

2.15 Type `esxi-host` for the `Provider resource name` field (all lowercase and no spaces)

2.16 Change the `Endpoint type` from vCenter to `ESXi`

2.17 Type in the `URL` (i.e. https://1.1.1.1/sdk)

2.18 Type in `{{BASTION_IP_ADDR}}/YOUR_PROJECT/vddk:2` for the `VDDK init image` path field

2.19 Type in the ESXi username for `Username`

2.20  Type in the ESXi password for the `Password`

2.21 Click the `Skip certificate validation` radio button

2.22 Click the blue `Create provider` button 

![](docs/images/screenshots/createSourceProvider3.PNG "create source provider")

### Now we will configure the `Migration Toolkit` operator so that it can see the OpenShift virtualization environment where the vms will be migrated to

> In the first few steps we will get the OpenShift API token for your user so that we can add that credential. Note: some steps will be a repeat from above.

2.23 Click the down arrow next to your username at the top right

2.24 Click `Copy Login Command`

![](docs/images/screenshots/getAPIToken1.PNG "get api token")

2.25 Click `{{LOGIN_BUTTON}}` to verify login

![](docs/images/screenshots/getAPIToken2.PNG "get api token")

2.26 Type in your username and password and click `Login`

![](docs/images/screenshots/getAPIToken3.PNG "get api token")

2.27 Click `Display Token`

![](docs/images/screenshots/getAPIToken4.PNG "get api token")

2.28 Copy the line where your `sha256~....` token is displayed

![](docs/images/screenshots/getAPIToken5.PNG "get api token")

2.29 Click `Migration` --> `Providers for virtualization` in the left navigation menu. NOTE: This is a second provider being added, so some steps will be a repeat from earlier.

2.30 Ensure Project is set to `{{PROJECT_NAME}}` at the top 

2.31 Click `Create Provider`

![](docs/images/screenshots/createSourceProvider-ocp.PNG "create source provider")

2.32 Select `Openshift Virtualization` for the provider type

2.33 Type `ocpvirt` for the `Provider resource name`

2.34 Type `{{OPENSHIFT_CLUSTER_API_URL}}` for the URL

2.35 Paste in your sha256~ token value that you copied earlier into the `Service account bearer token` field

2.36 Click the `Skip certificate validation` radio button

2.37 Click `Create Provider`

![](docs/images/screenshots/createTargetProvider2.PNG "create target provider")

### In this next section we will modify a default setting for the maximum number of VMs that can be imported simultaneously. This is to prevent resource contraint related issues

2.38 Click `Operators` --> `Installed Operators` in the left navigation menu

2.39 Ensure project is set to `All Projects` at the top

2.40 Select the `Migration Toolkit for Virtualization Operator` option 

![](docs/images/screenshots/edit_max_inflight_1.PNG "edit max inflight")

2.41 Switch to the `ForkliftController` tab

2.42 Select the `FC forklift-controller` resource

![](docs/images/screenshots/edit_max_inflight_2.PNG "edit max inflight")

2.43 Switch to the `YAML` tab at the top and wait for it to load (text will colorize once resource is loaded)

2.44 Type `controller_max_vm_inflight: 5` immediately following the `spec:` line. (ensure proper spacing allignment) 

2.45 Click `Save` 
<!-- TODO: add screenshot -->

### Step 3: Create Migration Plan

3.1 Click `Migration` --> `Plans for virtualization` in the left navigation menu

3.2 Ensure project is set to `{{PROJECT_NAME}}` at the top

3.3 Click `Create Plan` 
<!-- TODO: add screenshot to create the migration plan -->

3.4 Select `esxi-host` source provider 

3.5 Once the list of available VMs is loaded, change the number of displayed results to 100 for easier selection process 

![](docs/images/screenshots/createMigrationPlan2.PNG "create migration plan")

3.6 Select vms intended to be migrated over 

3.7 Click `Next`

![](docs/images/screenshots/createMigrationPlan3.PNG "create migration plan")

3.8 Type `vm-migration-initial` for the `Plan name` field. (all lowercase and no spaces)

3.9 Verify the number of `Selected VMs` is what you expect

3.10 Select `ocpvirt` for the `Target provider`

3.11 Ensure `YOUR_PROJECT` is selected for `Target namespace`

3.12 Complete the network mappings by matching the appropriate vlan ids

3.13 Verify storage map is set to `basic-csi` on the right. 

3.14 Click `Create migration plan`

![](docs/images/screenshots/createMigrationPlan4.PNG "create migration plan")

3.15 Wait for Migration Plan to be validated (you can expect to see a Warning flag and this validation may take several minutes before the next button is available) 

![](docs/images/screenshots/createMigrationPlan5.PNG "create migration plan")

3.16 Once validation is complete, click `Start Migration` button. 

![](docs/images/screenshots/createMigrationPlan6.PNG "create migration plan")

3.17 Click `Start`

![](docs/images/screenshots/createMigrationPlan7.PNG "create migration plan")

3.18 Once the migration has started the page should display some progress bars

![](docs/images/screenshots/createMigrationPlan8.PNG "create migration plan")

3.19 Switch to `Virtual Machines` tab to monitor progress

![](docs/images/screenshots/createMigrationPlan9.PNG "create migration plan")

## Step 4: Post Migration Update to VMs to update drivers

4.1 Once all VMs have been migrated, go back to bastion console

4.2 Change directory to the config repo if not already there (i.e. /opt/ocp4-disconnected-config)

4.3 Run command `./scripts/update-drivers.sh`

4.4 Go back to the Openshift Console in the browser window

4.5 Select `Virtualization` --> `VirtualMachines` in the left navigation menu

4.6 Ensure the project is set to `YOUR_PROJECT` at the top

4.7 You should see a list of your migrated virtual machines on this screen and be able to click on them to manage them.

## 5 Troubleshooting and more information

## 6 Alternate migration method (manual ova copy instructions)
