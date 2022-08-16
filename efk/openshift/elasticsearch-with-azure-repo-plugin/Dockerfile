FROM registry.connect.redhat.com/elastic/elasticsearch:7.15.0
RUN bin/elasticsearch-plugin install --batch repository-azure

LABEL maintainer="mazumdar.pinak@gmail.com" \
      image-description="custom elasticsearch image with base image of UBI"
      