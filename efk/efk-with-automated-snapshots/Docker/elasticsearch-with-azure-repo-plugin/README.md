# Description:

Dockerfile to create custom Elasticsearch application application based on version base image of elasticsearch.
This dockerfile  will install only the azure-repository plugin as I needed only this but you can extend this to have all the necessary plugins pre-loaded rather than installing them through an init container.
