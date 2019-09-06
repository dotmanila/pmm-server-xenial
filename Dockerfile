FROM ubuntu:16.04
WORKDIR /opt
USER root
RUN adduser --disabled-password --uid 1001 pmm
RUN apt update
RUN apt install -y software-properties-common python-software-properties \
    eatmydata python-pip tzdata wget locales libfontconfig unzip strace
RUN apt update
RUN pip install supervisor requests
RUN mkdir -p \
    /opt/deb \
    /opt/packages \
    /var/lib/consul \
    /etc/consul.d \
    /usr/share/orchestrator \
    /var/lib/prometheus \
    /var/log/supervisor \
    /usr/share/prometheus \
    /usr/share/prometheus1 \
    /usr/share/percona-dashboards \
    /qan-api \
    /srv/logs \
    /srv/postgres \
    /srv/grafana \
    /srv/prometheus \
    /srv/update \
    /etc/tmpfiles.d \
    /usr/pgsql-10 \
    /usr/local/percona \
    /var/run/supervisor
COPY packages/consul /usr/sbin/
COPY packages/node_exporter-0.18.1.linux-amd64/node_exporter /usr/sbin/
COPY packages/prometheus-2.12.0.linux-amd64/prometheus /usr/sbin/
COPY packages/prometheus-2.12.0.linux-amd64/prometheus /usr/sbin/prometheus1
COPY packages/prometheus-2.12.0.linux-amd64/promtool /usr/bin
COPY packages/prometheus-2.12.0.linux-amd64/consoles /usr/share/prometheus/
COPY packages/prometheus-2.12.0.linux-amd64/consoles /usr/share/prometheus1/
COPY packages/prometheus-2.12.0.linux-amd64/console_libraries /usr/share/prometheus/
COPY packages/prometheus-2.12.0.linux-amd64/console_libraries /usr/share/prometheus1/
COPY bin/qan-api2 /usr/sbin/percona-qan-api2
COPY bin/pmm-managed /usr/sbin/pmm-managed
COPY bin/pmm-agent /usr/sbin/pmm-agent
COPY bin/pmm-configurator /usr/sbin/pmm-configurator
COPY bin/mysqld_exporter /usr/local/percona/
COPY bin/node_exporter /usr/local/percona/
COPY bin/mongodb_exporter /usr/local/percona/
COPY bin/proxysql_exporter /usr/local/percona/
COPY bin/postgres_exporter /usr/local/percona/
COPY bin/mysqld_exporter /usr/bin/
COPY bin/node_exporter /usr/bin/
COPY bin/mongodb_exporter /usr/bin/
COPY bin/proxysql_exporter /usr/bin/
COPY bin/postgres_exporter /usr/bin/
COPY packages/pgsql-10 /usr/pgsql-10
COPY packages/pmm-server-2.0.0-beta6 /usr/share/pmm-server
COPY packages/grafana-dashboards-2.0.0-beta6 /usr/share/percona-dashboards
COPY files/import-dashboards.py /usr/share/percona-dashboards/
ADD deb/* /opt/deb/
ENV DEBIAN_FRONTEND=noninteractive
RUN dpkg -i /opt/deb/*.deb
COPY packages/pmm-server-2.0.0-beta6/prometheus.yml /etc/prometheus.yml
COPY files/clickhouse.xml /etc/clickhouse-server/config.xml
COPY files/supervisord.conf /etc/supervisord.conf
COPY files/pmm.ini /etc/supervisord.d/pmm.ini
COPY files/nginx.conf /etc/nginx/nginx.conf
# I don't know where this comes from either
COPY files/dashboards-VERSION /usr/share/percona-dashboards/VERSION
COPY files/nginx-pmm.conf /etc/nginx/conf.d/pmm.conf
COPY packages/pmm-server-2.0.0-beta6/nginx-ssl.conf /etc/nginx/conf.d/pmm-ssl.conf
COPY files/ca-certs.pem /srv/nginx/ca-certs.pem
COPY files/certificate.key /srv/nginx/certificate.key
COPY files/certificate.crt /srv/nginx/certificate.crt
COPY files/certificate.conf /srv/nginx/certificate.conf
COPY files/dhparam.pem /srv/nginx/dhparam.pem
COPY files/entrypoint.sh /opt/entrypoint.sh
COPY packages/pmm-server-2.0.0-beta6/tmpfiles.d-pmm.conf /etc/tmpfiles.d/pmm.conf
RUN chmod 0755 /opt/entrypoint.sh /usr/share/percona-dashboards/import-dashboards.py
RUN chmod 0644 /srv/nginx/*
# hack!
RUN sed -i 's/listen       80/listen 8888/g' /etc/nginx/conf.d/default.conf
RUN for f in /usr/share/percona-dashboards/panels/*.zip; do echo $f; unzip $f -d /var/lib/grafana/plugins/; done
RUN rm -rf /var/lib/apt/lists/* /var/cache/debconf /tmp/* \
    && apt-get clean
RUN chown -R pmm.pmm \
    /srv \
    /var/lib/consul \
    /opt \
    /qan-api \
    /var/lib/prometheus \
    /var/lib/grafana \
    /var/lib/clickhouse \
    /etc/supervisord.d \
    /etc/supervisord.conf \
    /etc/clickhouse-server \
    /etc/clickhouse-client \
    /etc/prometheus.yml \
    /etc/nginx \
    /etc/tmpfiles.d \
    /etc/grafana \
    /var/log/nginx \
    /var/log/supervisor \
    /var/cache/nginx \
    /usr/share/pmm-server \
    /usr/share/percona-dashboards \
    /usr/share/grafana \
    /usr/local/percona \
    /var/run/supervisor
RUN chmod 0700 /srv/postgres
RUN rm -f /etc/nginx/conf.d/default.conf
RUN sed -i 's/kernel.yama.ptrace_scope = 1/kernel.yama.ptrace_scope = 0/g' /etc/sysctl.d/10-ptrace.conf
USER pmm
RUN /usr/bin/clickhouse-server --config-file=/etc/clickhouse-server/config.xml --daemon --pidfile=/tmp/clickhouse.pid \
    && sleep 5 \
    && /usr/bin/clickhouse-client -h 127.0.0.1 -q 'CREATE DATABASE IF NOT EXISTS pmm' \
    && /bin/kill -INT $(cat /tmp/clickhouse.pid)
RUN /usr/pgsql-10/bin/initdb -D /srv/postgres
RUN /usr/pgsql-10/bin/pg_ctl -D /srv/postgres start \
    && /usr/pgsql-10/bin/psql -S -d postgres -c "create user \"pmm-managed\" password 'md5da757ec3e22c6d86a2bb8e70307fa937'" \
    && /usr/pgsql-10/bin/psql -S -d postgres -c "ALTER USER \"pmm-managed\" WITH SUPERUSER" \
    && /usr/pgsql-10/bin/createdb --owner pmm-managed pmm-managed \
    && /usr/pgsql-10/bin/psql -S -d pmm-managed -c "CREATE EXTENSION pg_stat_statements" \
    && kill -INT $(head -n1 /srv/postgres/postmaster.pid)
RUN mkdir -p /srv/postgres/log
CMD /opt/entrypoint.sh
