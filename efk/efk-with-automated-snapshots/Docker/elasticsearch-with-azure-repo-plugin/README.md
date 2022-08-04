# Description:

Dockerfile to create custom Elasticsearch application application based on the official base image of elasticsearch.
Primarily I  built this for openshift but the same can be also used for deploying on other k8s  clusters.
This dockerfile  will install only the azure-repository plugin as I needed only this but you can extend this to have all the necessary plugins pre-loaded rather than installing them through an init container.
