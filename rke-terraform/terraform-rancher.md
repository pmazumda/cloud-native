# Install/Upgrade Rancher on a Kubernetes Cluster.

## Pre-requisites:

1. Kubernetes Cluster
2. CLI Tools
3. Terraform


1. Kubernetes Cluster:

Rancher can be installed on any k8s cluster, be it AKS, EKS, GKE etc but for this we  have used RKE which is
Rancher's own distibution of its kubernetes engine also called Rancher Kubernetes Engine.

For detailed instructions on how to setup a RKE cluster, refer here: https://docs.ranchermanager.rancher.io/how-to-guides/new-user-guides/kubernetes-cluster-setup/rke1-for-rancher

2. CLI Tools 

The following CLI tools are required for setting up the Kubernetes cluster. Please make sure these tools are installed and available in your $PATH.

- kubectl - Kubernetes command-line tool.
- helm - Package management for Kubernetes. Refer to the Helm version requirements to choose a version of Helm to install Rancher. Refer to the instructions provided by the Helm project for your specific platform.

# Managing clusters with Rancher. 

Rancher is a software stack which helps in kubernetes cluster management by providing a centralized authentication, access control and observability platform, it streamlines cluster deployment on baremetal, private or public clouds. Refer  the doc for a  brief overview on how to deploy rancher, create a cluster and deploy applications on it. 

## Install Rancher using the HELM CHART

Rancher is installed using the Helm package manager for Kubernetes, Refer to the Helm version[https://docs.ranchermanager.rancher.io/getting-started/installation-and-upgrade/resources/helm-version-requirements] requirements to choose a version of Helm to install Rancher.

Rancher is available from three different repositories, we use the stable repository to fetch stable versions of rancher images. This is recommended for production environments.

`helm repo add rancher-stable https://releases.rancher.com/server-charts/<CHART-REPO>`

where CHART-REPO can be :

* latest
* stable
* alpha

Rancher Helm chart versions match the Rancher version (i.e appVersion). 
    
`helm repo add rancher-stable https://releases.rancher.com/server-charts/stable`

We'll need to define a Kubernetes namespace where the resources created by the Chart should be installed. This should always be cattle-system:

`kubectl create namespace cattle-system`

Once you've added the repo you can search it to show available versions with the following command:

`helm search repo rancher-stable/rancher --versions`

### Choose your SSL Configuration
The Rancher management server is designed to be secure by default and requires SSL/TLS configuration.
We used  the option to use our own certificates.This option allows you to bring your own public- or private-CA signed certificate. Rancher will use that certificate to secure websocket and HTTPS traffic. In this case, you must upload this certificate (and associated key) as PEM-encoded files with the name tls.crt and tls.key. If you are using a private CA, you must also upload that certificate. This is due to the fact that this private CA may not be trusted by your nodes. Rancher will take that CA certificate, and generate a checksum from it, which the various Rancher components will use to validate their connection to Rancher.

Please note to combine the server certificate followed by any intermediate certificate(s) needed into a file named tls.crt. Copy your certificate key into a file named tls.key.

Use kubectl with the tls secret type to create the secrets.

```bash
kubectl -n cattle-system create secret tls tls-rancher-ingress \
  --cert=tls.crt \
  --key=tls.key
  ```

The command to install Rancher requires a domain name that forwards traffic to Rancher. If you are using the Helm CLI to set up a proof-of-concept, you can use a fake domain name when passing the hostname option. An example of a fake domain name would be <IP_OF_LINUX_NODE>.sslip.io, which would expose Rancher on an IP where it is running. Production installs would require a real domain name.

```bash
helm install rancher rancher-<CHART_REPO>/rancher \
  --namespace cattle-system \
  --set hostname=rancher.my.org \
  --set bootstrapPassword=admin \
  --set ingress.tls.source=secret
  ```

Refer: https://docs.ranchermanager.rancher.io/pages-for-subheaders/install-upgrade-on-a-kubernetes-cluster


Alternatively, we  have prepared a terraform file which can be also used to setup  the infrastructure. All of the above steps will be performed using terraform,terraform will install the RKE cluster. 

First, you want to make sure that you have the Terraform CLI installed on your machine and prepare  the VM's/ machines where you are gonna bring up your cluster. You can find the documentation on the Terraform docs.https://learn.hashicorp.com/tutorials/terraform/in



## Creating RKE cluster using Terraform and deploy Rancher into it. 

Checkout the following repo which contains the source code.Please bear in mind that if you are going to use it , you need to replace the environment specific variables.


The repository contains two folder structures, the terraform files present here  is responsible for bootstrapping the  RKE k8s cluster. 
Modify the variables.tf as per your needs. A working cluster.yml is  provided as an example, if you want to provide more options you can also have a look at this file.

The helm-release folder contains the terraform files required to deploy applications on the cluster. Checkout the terraform  files present inside the helm-release folder of the repository to deploy applications on our newly created RKE cluster.  

* variables.tf      - In this we have defined the variables that we want to use within our terraform deployment.
* helm-release.tf   - The 
* charts  directory - This  directory contains the  helm chart  needed to be installed or update the repository attribute in the  helm-release.tf file  to the repository url. 


Since we are adding the provider, we have to run the following command again to initialise it for the first time: 

`terraform init`


I have installed the rancher application using the helm provider here but you can install any application  using this.

First run the following command to see the resources that will be created,this command will show you any resources that terraform has to change, create, or destroy that the current state of your infrastructure needs as per the  the desired state defined in Terraform files. run:


`terraform plan`


If you are content with the changes that terraform will make within your cluster, run the following command:

`terraform apply`


And thats it, if all went well and we have our Kubernetes Cluster created and the Helm Charts deployed in less than an hour. 

Encountered Issues
----

The following issues were encountered during the setup of the rke cluster.

1. Failed running cluster err:[workerPlane] Failed to bring up Worker Plane: [Failed to verify healthcheck: Failed to ch]: Get "http://localhost:10248/healthz": Unable to access the service on localhost:10248. The service might be still st: failed to run Kubelet: unable to determine runtime API version: rpc error: code = Unavailable desc = connection error


Problem:

As of Kubernetes 1.24, dockershim is no longer part of the Kubernetes core so essentially it isnt really RKE that is causing this but chnage in Kubernetes 1.24 which causing this.

Solution:
If your cluster is using Docker Engine with dockershim as its container runtime, one option is to manually install cri-dockerd and migrate your nodes to stop using dockershim and start using cri-dockerd. 
Install cri-dockerd

This walkthrough assumes Docker Engine is already installed and running. You can use cri-dockerd with Linux or Windows Server nodes. Start by downloading the appropriate binary package from the cri-dockerd GitHub page.

On Linux, you can use wget:

$ wget https://github.com/Mirantis/cri-dockerd/releases/download/v0.2.0/cri-dockerd-v0.2.0-linux-amd64.tar.gz
In PowerShell on Windows Server, you can use Invoke-WebRequest. 

> Invoke-WebRequest -Uri https://github.com/Mirantis/cri-dockerd/releases/download/v0.2.0/cri-dockerd-v0.2.0-windows-amd64.zip -UseBasicParsing -o cri-dockerd.zip
Next, unzip the package. On Linux you can use:

$ tar xvf cri-dockerd-v0.2.0-linux-amd64.tar.gz
On Windows Server:

> Expand-Archive -LiteralPath cri-docker.zip -DestinationPath .
If you’re on Linux, move the cri-dockerd binary to your usr/local/bin directory:

$ sudo mv ./cri-dockerd /usr/local/bin/ 
On Windows, you can move the binary to your \Windows\System32 folder, or otherwise include it in your PATH: 

> Move-Item -Path cri-dockerd.exe -Destination C:\Windows\System32
Check to see if it is successfully installed:

$ cri-dockerd --help
You should see the help output explaining the flags you can use with the tool.

Start the service on Linux
Now you’ll need to configure systemd:


$ wget https://raw.githubusercontent.com/Mirantis/cri-dockerd/master/packaging/systemd/cri-docker.service
$ wget https://raw.githubusercontent.com/Mirantis/cri-dockerd/master/packaging/systemd/cri-docker.socket
$ sudo mv cri-docker.socket cri-docker.service /etc/systemd/system/
$ sudo sed -i -e 's,/usr/bin/cri-dockerd,/usr/local/bin/cri-dockerd,' /etc/systemd/system/cri-docker.service
…and start the service with cri-dockerd enabled:


$ systemctl daemon-reload
$ systemctl enable cri-docker.service
$ systemctl enable --now cri-docker.socket
You can verify that the service is running with:

$ systemctl status cri-docker.socket


Start the service on Windows
You can start cri-dockerd as a service on a Windows node using nssm.

If you have nssm installed, enter in PowerShell:

> nssm install cri-dockerd
Select the cri-dockerd executable (in C:\Windows\System32 or wherever it is located on your system). And then:

> nssm start cri-dockerd
You can check the service status with:

> nssm status cri-dockerd


Cordon and drain dockershim-dependent nodes
Now we’re going to cordon our node, which does exactly what it sounds like: we’re putting up warning tape around this node and telling the rest of the system not to schedule new pods here. 

$ kubectl cordon <NODE>
…where <NODE> is the name of the node in question (without the angle brackets). 

Next we’re going to drain the node, which means that we will safely and methodically kick out any currently running pods. 

$ kubectl drain <NODE> --ignore-daemonsets
With our node cordoned and drained, we can move on to configure the node to use cri-dockerd. 

Configure nodes to use cri-dockerd
Here, we’ll assume we’ve used kubeadm to configure our node. Use your text editor of choice to open the node’s kubeadm-flags.env file—I’m using nano in the example below. 

$ nano /var/lib/kubelet/kubeadm-flags.env
Inside the file, change the value of the --container-runtime-endpoint flag to: 

unix:///var/run/cri-dockerd.sock
Save the file. Next, we’ll need to update the Node object in the control plane. 

$ KUBECONFIG=/path/to/admin.conf kubectl edit no <NODE>
Again, <NODE> is the name of the node in question (without the angle brackets). Replace the file directory path with the appropriate path on your system, leading to the admin.conf configuration file.

Within the file, modify kubeadm.alpha.kubernetes.io/cri-socket from /var/run/dockershim.sock to unix:///var/run/cri-dockerd.sock.

Finally, save the changes. At this point, we can restart the kubelet:

$ systemctl restart kubelet
Verify that the node is using the correct adapter by running:

$ kubectl describe <NODE>
Under the annotations section, you should see a value specifying that the node uses cri-dockerd.sock. Now uncordon the node, and you’re done!

$ kubectl uncordon <NODE>

ref: https://www.mirantis.com/blog/how-to-install-cri-dockerd-and-migrate-nodes-from-dockershim/


2. Docker daemon stopped , cannot bring up with the following error
 Cannot connect to the Docker daemon at unix:/var/run/docker.sock. Is the docker daemon running?
 
 Solution:
 
 Stopped any stale processes running :
 ```bash
     ps axf | grep docker | grep -v grep | awk '{print "kill -9 " $1}' | sudo sh
	 ```
 Restarted docker process
 ```bash
    sudo systemctl start docker
	```