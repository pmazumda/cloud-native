# EFK Helm Chart with automaded snapshot feature.

If you are installing this chart for the first time you should install elastic-operator
In order to install, execute the following commands:

### Add the elastic chart repo in your local chart repo list

- `helm repo add elastic https://helm.elastic.co`

### Install the elastic-operator chart

- `helm install elastic-operator elastic/eck-operator -n elastic-system --create-namespace --version 2.3.0 --set image.repository=registry-url/eck-operator,image.tag=2.3.0`

### Check elastic-operator pod is running 

- `kubectl get pod -n elastic-system`


## Install the EFK chart by using

- `helm install efk-[CLUSTER_NAME] . -n efk-[CLUSTER_NAME] --create-namespace --dependency-update `
     
   you can add `--debug` option for troubleshooting.

- `CLUSTER_NAME`: Should be the cluster name, for example: core
- `VALUES_PATH`: If you want override chart default values, you should provide your file with custom values


To delete/uninstall the environment,execute `helm uninstall efk-[CLUSTER_NAME] -n efk-[CLUSTER_NAME] `.

Note:
### Enable CA signed certs
By default this chart will install EFK stack with self-signed certs.  If you want to install EFK with your own certs, place the cert and the key named as **tls.crt** and **tls.key** respectively inside the cert directory of the chart and overridden values as below can be passed to  default values.
```
 tls:
   # Enable the tls or not
   enabled: true
   secret:
     # The name of secret which would contain keys named:
     # "tls.crt" - the certificate ( CA signed )
     # "tls.key" - the private key
     secretName: "efk-tls"
```
