FROM registry.access.redhat.com/ubi8/ruby-30:1-40

LABEL maintainer "PINAK MAZUMDAR <mazumdar.pinak@gmail.com>"
LABEL Name ="fluentd" Description="Custom fluentd docker image for openshift built on UBI" Vendor="Fluent Organization" Version="1.14.6"

USER 0

RUN yum update -y --setopt=tsflags=nodocs \
 && yum install -y --setopt=tsflags=nodocs \
 --setopt=history_record=yes https://download-ib01.fedoraproject.org/pub/epel/8/Everything/x86_64/Packages/t/tini-0.19.0-1.el8.x86_64.rpm \
 && yum install -y ca-certificates \
 && yum install -y redhat-rpm-config \
 && yum install -y --setopt=tsflags=nodocs --setopt=history_record=yes \
 gcc-c++ ruby-devel libcurl-devel make cmake swig autoconf automake libtool m4
 
RUN echo 'gem: --no-document' >> /etc/gemrc \
 && gem install oj -v 3.10.18 \
 && gem install json -v 2.4.1 \
 && gem install async-http -v 0.54.0 \
 && gem install fluentd -v 1.14.6 \
 && gem install bigdecimal -v 1.4.4 \
 && rm -rf /tmp/* /var/tmp/* /usr/lib/ruby/gems/*/cache/*.gem /usr/lib/ruby/gems/3.*/gems/fluentd-*/test rm -rf /var/cache/* \
 && yum clean all \
 &&  groupadd  fluent && useradd -g fluent fluent \
    # for log storage (maybe shared with host)
    && mkdir -p /fluentd/log \
    # configuration/plugins path (default: copied from .)
    && mkdir -p /fluentd/etc /fluentd/plugins 


COPY fluentd.conf /fluentd/etc/
COPY entrypoint.sh /bin/

RUN chmod -R 777 /fluentd
RUN chown -R fluent /bin /fluentd && chgrp -R fluent /bin /fluentd 

ENV FLUENTD_CONF="fluentd.conf"

ENV LD_PRELOAD=""
EXPOSE 24224 5140 9880

USER fluent

ENTRYPOINT ["tini",  "--", "/bin/entrypoint.sh"]
CMD ["fluentd"]
