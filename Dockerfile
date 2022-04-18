FROM jruby:9.2.7-jdk-alpine

LABEL maintainer "hiro-hori <kazemachi3@gmail.com>"

ENV DIGDAG_VERSION=0.10.4 \
    DIGDAG_HOME=/var/lib/digdag \
    DOCKER_VERSION=20.10.14

RUN apk --no-cache add curl && \
    curl -o /usr/bin/digdag --create-dirs -L "https://dl.digdag.io/digdag-$DIGDAG_VERSION" && \
    chmod +x /usr/bin/digdag && \
    adduser -h $DIGDAG_HOME -g 'digdag user' -s /sbin/nologin -D digdag && \
    mkdir -p $DIGDAG_HOME/logs/tasks $DIGDAG_HOME/logs/server && \
    chown -R digdag.digdag $DIGDAG_HOME && \
    apk --no-cache add tzdata ca-certificates groff less bash jq python py-pip py-setuptools git findutils && \
    rm -rf /var/cache/apk/* && \
    # Docker
    curl "https://download.docker.com/linux/static/stable/x86_64/docker-$DOCKER_VERSION.tgz" | tar xvz -C /tmp && \
    mv /tmp/docker/* /usr/bin/ && \
    addgroup -g 497 docker && \
    adduser digdag docker && \
    # Embulk
    curl --create-dirs -o /usr/bin/embulk -L "https://dl.embulk.org/embulk-latest.jar" && \
    chmod +x /usr/bin/embulk && \
    # Python
    pip --no-cache-dir install awscli boto3

# COPY digdag.properties /etc/digdag.properties

USER digdag

# Embulk Plugins
# RUN embulk gem install \
#         embulk-input-s3 \
#         embulk-output-s3 \
#         embulk-input-gcs \
#         embulk-output-gcs \
#         embulk-input-bigquery \
#         embulk-output-bigquery

WORKDIR /var/lib/digdag

EXPOSE 65432
ENTRYPOINT ["/bin/sh", "/usr/bin/digdag"]
# CMD ["server", "--config", "/etc/digdag.properties", "--memory"]
