FROM couchbase:enterprise-7.0.0
RUN mkdir -p /opt/couchbase/scripts /health-scripts

RUN apt-get update \
    && apt-get install curl -y \
    && curl -sL https://deb.nodesource.com/setup_14.x | bash - \
    && apt-get update \
    && apt-get install nodejs -y

COPY ./scripts/* /opt/couchbase/scripts
RUN chmod +x /opt/couchbase/scripts/configure-node.sh \
    && cd /opt/couchbase/scripts \
    && npm install couchbase@3.1.2 interpolate-json

WORKDIR /opt/couchbase/scripts
CMD  /opt/couchbase/scripts/configure-node.sh