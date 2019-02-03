FROM roura/tengine
LABEL maintainer="Alberto Roura mail@albertoroura.com"

ENV DOCKER_GEN_VERSION 0.7.4
ENV DOCKER_HOST unix:///tmp/docker.sock
ENV AUTO_UPGRADE 1
ENV LE_WORKING_DIR /acme.sh
ENV LE_CONFIG_HOME /acmecerts

COPY app /app

RUN apt-get update \
    && apt-get install -y -q --no-install-recommends cron ca-certificates && apt-get clean \
    && rm -r /var/lib/apt/lists/* \
    && ln -s /app/network_internal.conf /etc/nginx/network_internal.conf \
    && mkdir -p /etc/nginx/dhparam && ln -s /app/dhparam.pem /etc/nginx/dhparam/dhparam.pem \
    && wget https://github.com/jwilder/docker-gen/releases/download/$DOCKER_GEN_VERSION/docker-gen-linux-amd64-$DOCKER_GEN_VERSION.tar.gz \
    && tar -C /usr/local/bin -xvzf docker-gen-linux-amd64-$DOCKER_GEN_VERSION.tar.gz \
    && rm /docker-gen-linux-amd64-$DOCKER_GEN_VERSION.tar.gz \
    && wget -O- https://get.acme.sh | sh && crontab -l | sed 's#> /dev/null##' | crontab - \
    && wget https://github.com/chrismytton/shoreman/raw/master/shoreman.sh -O /usr/local/bin/shoreman \
    && chmod +x /usr/local/bin/shoreman /app/docker-entrypoint /app/update_certs

WORKDIR /app

VOLUME ["/etc/nginx/certs", "/etc/nginx/stream.d", "/acmecerts"]
ENTRYPOINT ["/app/docker-entrypoint"]
CMD ["shoreman"]
