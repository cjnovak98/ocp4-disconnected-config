\pagebreak

![](docs/images/ocplogo.jpg "OCP Logo")

# Red Hat OpenShift Installation Guide


This guide covers the process for installing Red Hat OpenShift 4.15+ on Red Hat Enterprise Linux 9 with options for FIPS and STIG configurations. The instructions support deployment on both connected and disconnected environments.

## Prerequisites

### RHEL Install

**RHEL 9 Installation**: Install Red Hat Enterprise Linux 9 and register it with your Red Hat account (if connected to the internet).

> **NOTE:** If the goal is to have a FIPS-enabled cluster, the bastion host has to be FIPS-enabled as well. If you don't need FIPS, you can ignore the following configurations.

**Environment Configurations**:

> **NOTE:** These configurations can be done post install. Changes to usbguard/sysctl.conf will require a reboot, while fapolicyd will only require restart on the service.

1. Ensure **FIPS** mode is enabled for RHEL 9.
    - [Enable FIPS during installation](https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/9/html/security_hardening/switching-rhel-to-fips-mode_security-hardening#proc_installing-the-system-with-fips-mode-enabled_switching-rhel-to-fips-mode); or
    - [Enable FIPS post-installation](https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/9/html/security_hardening/switching-rhel-to-fips-mode_security-hardening#switching-the-system-to-fips-mode_using-the-system-wide-cryptographic-policies)
  
  
2. Configure **STIG** compliance as needed


3. Configure **fapolicyd** for Ansible Playbooks:

    - Allow regular users to run Ansible playbooks by creating a new file at `/etc/fapolicyd/rules.d/22-ansible.rules` with the following contents:

    ```bash
    allow perm=any uid=1000 : dir=/home/user/.ansible
    allow perm=any uid=1000 : dir=/home/user/.cache/agent
    allow perm=any uid=1000 : dir=/usr/share/git-core/templates/hooks
    allow perm=any uid=1000 : dir=/pods
    allow perm=any uid=1000 : dir=/usr/bin
    allow perm=any uid=0,1000 : dir=/tmp
    ```
    > **NOTE:** This was what was used for testing, you can use Group Identifier (GID) or User Ieentifer (ID). I used UID because it more narrow scoped that GID. Policy and best jugement should dictate which route you do

4. Adjust User Namespace Limits for Registry Pod:
    
    - Increase the `user.max_user_namespaces` setting to enable the registry pod to run as a non-root user. Update `/etc/sysctl.conf` as follows:

    ```bash
    # Per CCE-83956-3: Set user.max_user_namespaces = 0 in /etc/sysctl.conf
    user.max_user_namespaces = 5
    ```

5. Enable Access to External USB Devices (for Disconnected Environments):
    
    - Add the following commands to the `%post` section in your kickstart file:

    ```bash
    systemctl disable usbguard
    sed -i 's/black/\#black/g' /etc/modprobe.d/usb-storage.conf
    sed -i 's/install/\#install/g' /etc/modprobe.d/usb-storage.conf
    ```

6. Install Ansible/Podman:

    ```bash
    sudo dnf install -y ansible-core container-tools
    ```



## Running the Automation

  **Getting Collection installed (connected side or connected cluster)**

  1. Clone this Repository:

      ```bash
      git clone https://github.com/cjnovak98/ocp4-disconnected-config
      ```

  2. Navigate to the Playbooks Directory:
      ```bash
      cd ocp4-disconnected-config/playbooks
      ```

  3. Install Required Ansible Collections( 1st time/connected system ): 

      > **NOTE:** This will install [disconnected-collection](https://github.com/cjnovak98/ocp4-disconnected-collection) and should be run on a fresh system, before anything else has been run.

      ```shell
      ansible-playbook initial-ansible-collection.yml
      ```
      or

      ```shell
      ./initial-ansible-collection.yml
      ```

### Directory Structure Assumptions

Ensure that the content resides in `/pods/content` (definable in `playbooks/group_vars/all/cluster-deployment.yml`). It is assumed this is the transferable media when running connected side for a disconnected cluster and disconnected config is /pods/content/ansible

### Run Content Gathering Playbook to Prepare Disconnected Environments:

> **NOTE:** Ensure a valid pull secret exists. You can get your pull secret from [https://console.redhat.com/openshift/create/local](https://console.redhat.com/openshift/create/local) and store it in `~/.docker/config` on the host where you're running the automation. 

#### Update Environment Variables

Modify `group_vars/all/cluster-version.yml` to customize it for your environment. Key variables include:

- common_openshift_release: Target cluster version
- common_previous_openshift_release: Previous version, used for updates
- common_trident_version: trident target version
- content_generation_disconnected_operators: Array of all Catalog sources Openshift will use
  - redhat-operator-index: Name of this catalog source
    - name: Name of any operator to pull within this catalog source
      - channel: specific version of operator to pull on
  - redhat-marketplace-index:
  - community-operator-index:
  - certified-operator-index:
- content_generation_additionalImages: an array of addtinal images to pull

```yaml
# Example group_vars/all/cluster-version.yml

common_openshift_release: 4.16.4
common_previous_openshift_release: 4.16.3
common_trident_version: v24.06.0


# Disconnected Images

#content_generation_pull_mirror: true

## Operators To be mirrored, based on index they are in
content_generation_disconnected_operators:
  - redhat-operator-index:
    - name: kubernetes-nmstate-operator
    - name: kubevirt-hyperconverged
  - redhat-marketplace-index:
  - community-operator-index:
  - certified-operator-index:

## additionalImages for oc-mirror to pull. Include version
content_generation_additionalImages:
  - name: registry.redhat.io/ubi8/ubi:latest
  - name: registry.redhat.io/ubi9/ubi:latest
  - name: quay.io/noseka1/toolbox-container:full
```
> **NOTE:** for the operator portion of cluster-versions, if nothing is definded as an operator for a catalog source, the entire source is omitied, it is the same design for channel, however the latest is pulled vs being omitied

#### Run the automation

If you are deploying on a disconnected system then you will first need to gather all of the openshift content on a machine that has internet connection and transfer it over. There is a playbook that you can run which will gather the appropriate content: 

```bash
ansible-playbook -K gather-content.yml
```
or 

```bash
./gather-content.yml
```

Once you have the content downloaded, transfer it to your disconnected machine and put in the content directory (i.e. /pods/content), you will also need the `ocp4-disconnected-config` folder used to run this playbook

### Install the Collection on a Disconnected Machine

You can either transfter the content from the media used to get it to the disconnected side, or update `playbooks/group_vars/all/cluster-deployment.yml` to point to the mount point of the media

> **Example:** For testing, im running from a 1TB external drive, mounted in `/pods/content` and the 
dirctory structure was:

```bash
ls /pods/content
bin   downloads   images   ocp4-disconnected-config
```

Install required Ansible Collection from the previous step: 

> **NOTE:** This will install need the media to be mounted, the group vars set, and be in the `ocp4-disconnected-config/playbooks` directory

```bash
ansible-playbook disconnected-ansible-collection.yml
```
or

```bash
./disconnected-ansible-collection.yml
```

### Run the Deployment Playbook

#### Update Environment Variables

- Modify `group_vars/all/cluster-deployment.yml` to customize it for your environment. Key variables include:
  - `common_openshift_dir`: Directory for pulled content to live.
  - `common_connected_cluster`: Set to `true` if the cluster itself is connected.
  - `mirror_content_pull_mirror`: Set to `true` to pull content (set to `false` for disconnected environments).
  - `common_fips_enabled`: `true` if the host is stigged and FIPS is enabled.
  - `common_cluster_domain`: Top-Level Domain (TLD) for the cluster.
  - `common_ip_space`: First three octets of the IP address range for both the bastion and cluster.
  - `common_nodes`: Details of nodes, including name, last octet of the node IP, and MAC addresses.
  - `idracs_user` and `idracs_password`: iDRAC credentials.
  - `idracs`: Node name and IP of the node’s iDRAC.

```yaml
# Example playbooks/group_vars/all/cluster-deployment.yml

common_git_repos:
  - "https://github.com/cjnovak98/ocp4-disconnected-collection.git"
  - "https://github.com/cjnovak98/ocp4-disconnected-config"

common_openshift_dir: /pods/content
common_connected_cluster: false
mirror_content_pull_mirror: false

common_openshift_interface: ens1
common_fips_enabled: true
common_cluster_domain: example.com

common_ip_space: 192.168.122
common_nodes:
  - name: master-0
    ip: '42'
    mac: 52:54:00:8d:13:77
  - name: worker-0
    ip: '43'
    mac: 52:54:00:8d:13:78

# iDRAC
#idrac_user: test
#idrac_password: tester

#media_share_idracs:
#  - name: master-0
#    ip: '{{ ip_space }}.5'
#  - name: master-1
#    ip: '{{ ip_space }}.6'
#  - name: master-2
#    ip: '{{ ip_space }}.7'
#  - name: worker-0
#    ip: '{{ ip_space }}.8'
```

> **NOTE:** if cluster hardware supports idrac, uncomment to idrac vars.

For both connected and disconnected clusters, deploy the cluster by running:

```bash
ansible-playbook -K deploy-cluster.yml
```
or
```bash
./deploy-cluster.yml
```

### Fix DNS for disconnected cluser without a DNS Server

If you are running a disconnected server (or atleast on a network with no DNS), We recommend that you now point your bastion at master-0 node to be able to resolve cluster resources (ingress/api) 


1. Open nmtui Interface:

    Run the following command in your terminal:

    ```bash
    sudo nmtui
    ```

2. Select "Edit a Connection":

    Use the arrow keys to navigate to Edit a connection and press Enter.


3. Choose Your Interface:

    Highlight the interface that lives in the same IP space and VLAN as your soon to be deployed cluster (e.g. eth0, or eth0.670).

    Press Enter to edit the selected connection.


4. Edit IPv4:

    Use the arrow keys to navigate to IPv4 CONFIGURATION.


5. Add DNS Server:

    Navigate to the DNS servers field.

    Enter the IP of master-0.


6. Save Changes:

    Use the arrow keys to navigate to `OK` and press Enter to save the settings.


7. Activate the Connection:

    Navigate back to the main nmtui menu and select Activate a connection.

    Highlight the interface you just edited, and press Enter to deactivate and reactivate the connection, applying the changes.


8. Verify the DNS Settings:

    Run the following command to ensure the DNS server is correctly applied:

    ```bash
    nmcli dev show <interface_name> | grep IP4.DNS
    ```
    Replace ```<interface_name>``` with the name of your network interface.

9. Test with oc:

    You can test resolution with oc by running the following:

    ```bash
    oc whoami
    ```

    It should return: 

    ```bash
    sysadmin
    ```

### Add an additional node

#### Check Variables

Validate the variables definded from the `Run the Deployment Playbook` portion above

> **NOTE:** Double check the `add_worker_disk_type: sda` playbooks/group_vars/all/cluster-deployment.yml matches the actual disk type of the target nodes; i.e. vda (virtual drives), sda (sata drives), or nvme drives.

#### Run the playbook

```bash
ansible-playbook -K create-worker-for-single-node.yml
```

or

```bash
./create-worker-for-single-node.yml
```

> **NOTE:** DNS needs to be functional as definded in the previous section, or it will fail when pulling the worker ignition file from the "cluster".