# OCP GitOps Day 1

This helm chart is in charge of some basic setup after the initial deployment of OpenShift.

The idea behind this is that without OpenShift GitOps, working with an easily observable and maintainable infrastructure as code setup becomes hard. This template essentially just sets up that GitOps installation to where is is useful for the next steps (day2) where the bulk of the cluster configuration is performed.

This helm chart currently is responsible for the initial deployment and configuration of the OpenShift GitOps operator, including the automated setup of the ArgoCD application for the 'Day 2' operations. 

### Values

In order to properly run this chart, you will need to either modify the existing values.yaml file or create your own values file specifying the values relevant to your setup.

This can be built by copying the existing [values.yaml](values.yaml), and adjusting accordingly.

Mainly, you will need the IP of the system you ran the Ansible from, which is where resources are hosted for the disconnected install, as well as for continued GitOps work. You will also need the ssh private key of the user that was used to run the Ansible, as that is in turn used to access the Git repository for the aforementioned GitOps. Example values file:

```yaml
gitOps:
  #the namespace where the argocd instance will reside, defaults to openshift-gitops since that is the standard
  namespace: openshift-gitops
  #This source variable represents the catalog source where the operator lives. For disconnected installs use the cs-redhat-operator-index. For connected installs you can remove this variable and it will default to the connected catalog of redhat-operators.
  source: cs-redhat-operator-index

gitRepoTemplate:
  # The URL of the repository setup in the Ansible step. replace the IP with that of your syscon
  url: git@<ip of syscon>:repos/ocp4-disconnected-config
  # The SSH key of the user that ran the Ansible step, used to connect to the git repo. Be sure to include the 'BEGIN' and 'END' lines and also be sure the alignment ins consistent.
  sshPrivateKey: |
    -----BEGIN OPENSSH PRIVATE KEY-----
    -----END OPENSSH PRIVATE KEY-----
```

## Usage

To apply this template to your cluster, simply run the helm install command:

```bash
helm install gitops-day1 . --values=./your/values.yaml
```

This applies the yaml to the cluster, and will perform the day 1 operations. Note that it might take a few minutes for everything to come up and be ready, so be patient. You can tell the installation has finished and was successful by navigating to ArgoCD (top right apps menu in OCP web ui -> ArgoCD), clicking 'Log in via OpenShift', and seeing the ArgoCD dashboard. You should see the cluster-day2 app already loaded and attempting to sync. If not you can create the day 2 application manually. You should also see your git repository that's hosted on the syscon by navigating to Settings (on the left) -> Repositories. You should see your gitOps git repo in the list, with a green checkmark indicating success.

You can also use the following command to output the finished product without actually applying it to OpenShift, in order to debug and check:

```bash
helm template test . --debug | less
```


