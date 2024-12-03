# OCP 4 Disconnected Config Day2 Helm Chart

This chart applies the cluster settings and resources necessary for day to day operations in the target environment. It is intended to be deployed via OpenShift GitOps as part of a infrastructure as code process.

In this case, comments have been provided in both the default `values.yaml` and each of the `.yaml` files in the `templates/` directory to help explain each component.

## Deployment

### Configuring the Template

To use, you will simply add an application in ArgoCD (Openshift GitOps), and supply this repo/directory, as well as the values file customized for your environment.

Since the intent is to have ArgoCD automatically sync your configurations, it is important to first ensure you have prepared the appropriate values for your environment. When creating the application manually in argoCD you have the option to override the values but it is recommended to maintain the values in a file that can be managed and updated as needed. This method also allows for a more automated method of creating the ArgoCD application. To do this, it is recommended that you copy the default values file found at: `./helm/openshift-gitops-day2/values.yml` to a separate file, like `./helm/openshift-gitops-day2/day2-values-prod.yml`. 

This template expects the following cluster specific configurations for the following in your helm values:

1. Cluster-wide certificiates
2. Networking configurations for each node in your cluster
3. LDAP sync configuration
4. Chrony configuration
5. Storage configuration

The example values file structure can be seen [here](values.yaml)


### Configuring ArgoCD (Openshift Gitops) 

To do this you can run the following command:

```bash
oc apply -f ./cluster-day2-app.yml
```

To create the ArgoCD application manually you can use similar values to the below:

- Application Name: `cluster-day2`
- Project Name: `default`
- Sync Policy: `Automatic`
- Source:
  - Repository URL: Select the `ocp4-disconnected-config` repo running on the bastion host
  - Revision: `HEAD` (or override to your desired branch)
  - Path: `./helm/openshift-gitops-day2`
- Destination:
  - Cluster URL: `https://kubernetes.default.svc` # Use this value to target the same cluster that Argo is running on.
  - Namespace: leave blank or set to default if required
- Values:
  - Override the values as needed. If Argo was able to successfully connect to the source repo configuration, then you should see a list of optional values to override. You can also upload your own `values.yaml` file.

To get to Argo, simply select it from the top right dropdown on the OpenShift web ui.

You can also use the following command to see what will be applied before actually applying:

```bash
helm template test . --debug | less
```

The default [values.yaml](values.yaml) is designed to be give you the basic layout, as well as provide a template for your own custom values file. Simply make a copy of this default, and start filling in your real-world data. You can even run the above template command, adding `-f /path/to/yourValues.yaml` before the `|` to tell Helm to use your new file, in order to check your work.

## Components overview

### nmstate operator

Relevant templates:

 - [nmstate-namespace.yaml](templates/0-nmstate-namespace.yaml)
 - [nmstate-operatorgroup.yaml](templates/2-nmstate-operatorgroup.yaml)
 - [nmstate-operator.yaml](templates/3-nmstate-operator.yaml)
 - [nmstate-instance.yaml](templates/4-nmstate-instance.yaml)
 - [nmstate-nncp-bond.yaml](templates/5-nmstate-nncp-bond.yaml)
 - [nmstate-nncp-nodes.yaml](templates/5-nmstate-nncp-nodes.yaml)

The nmstate operator is what brings in the NodeNetworkConfigurationPolicy CRD's , allowing us to further tweak the network setup of the cluster.

### Chrony

Relevant templates:

 - [chrony-configuration.yaml](templates/6-chrony-configuration.yaml)

### LDAP

Relevant templates:

 - [ldap-accounts,secret,and oauth provider](templates/5-ldap-config.yaml)

### Storage

Relevant templates:

 - [trident-sc.yaml](templates/5-trident-sc.yaml)
 - NOTE Will trigger a reboot of the cluster: [trident-machineconfig-master.yaml](templates/6-trident-machineconfig-master.yaml)
 - NOTE Will trigger a reboot of the cluster: [trident-machineconfig-worker.yaml](templates/6-trident-machineconfig-worker.yaml)

Most Kubernetes distributions come with the packages and utilities to mount NFS backends installed by default, including Red Hat OpenShift.

However, for NFSv3, there is no mechanism to negotiate concurrency between the client and the server. Hence the maximum number of client-side sunrpc slot table entries must be manually synced with supported value on the server to ensure the best performance for the NFS connection without the server having to decrease the window size of the connection.

For ONTAP, the supported maximum number of sunrpc slot table entries is 128 i.e. ONTAP can serve 128 concurrent NFS requests at a time. However, by default, Red Hat CoreOS/Red Hat Enterprise Linux has maximum of 65,536 sunrpc slot table entries per connection. We need to set this value to 128 and this can be done using Machine Config Operator (MCO) in OpenShift.

For more information see [https://docs.netapp.corn/us-en/netapp-solutions/containers/rh-
os-n overview trident.html#nfs](https://docs.netapp.com/us-en/netapp-solutions/containers/rh-os-n_overview_trident.html#nfs)

### Other

#### Proxy

Relevant templates:

 - [proxy-custom-ca-cm.yaml](templates/5-proxy-custom-ca-config.yaml)

#### Ingress

Relevant templates:

 - [ingress-config.yaml](templates/5-ingress-config.yaml)
