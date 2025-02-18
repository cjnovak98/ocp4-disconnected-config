# THIS REPO IS ARCHIVED. Further dev will happen on forks of this repo.

![](docs/images/Red_Hat_Logo_2019.png "Red Hat Logo")

# Openshift 4 Disconnected Collection

## Overview

### The why
- The goal of this repository is to provide a standardized workflow for deploying OpenShift 4 in a disconnected environment using an agent-based installer.

### The how
- The idea is to have all variables set in group_vars/all, with some defaults set in roles. The defaults in roles are only applied in case they are not set in group_vars.

#### Variables
- cluster_version: This variable controls the version of the cluster and allows for the pulling of operators and additional images (for the cluster) via oc-mirror. This requires an active subscription with a pull secret in ~/.docker/config.json. It will pull all the required binaries along with some additional nice-to-haves (such as Butane).

- cluster_deployment: This variable controls how the cluster is deployed. It will generate the install-config and agent-config based on configured variables. 
- static this is used to set things that very rarely change or set variables defined in other vars, that are built ontop of other variables

#### Some assumptions include:
- SSH keys will not exist.
- SSL certificates for the hosted registry will be generated, which will run on the disconnected host.
Post-Install Configuration

#### Goals
- The current goal for post-install configuration is to deploy ArgoCD and have it manage the configuration and enforcement.

- To assist with this, a local Git repository will be configured as described in [this article.](https://thenewstack.io/create-a-local-git-repository-on-linux-with-the-help-of-ssh/)

#### Status
- This is a work in progress, and we will continue to make enhancements over time.

#### Requirements (disconnected system)
- Packages:
  - nmstate
  - openssl
  - httpd-tools
- Ansible-collections
  - dellemc.openmanage

## Additional Info:
[View notes on recommended procedures for vm migrations](/docs/vm-migration-notes.adoc)

## Thanks:
This started as as a fork from [hyperkineticnerd/ansible-ocp4-agent](https://github.com/hyperkineticnerd/ansible-ocp4-agent), but we have since diverged quite a bit away, but still would like to give credit.


