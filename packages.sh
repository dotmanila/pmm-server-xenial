#!/bin/bash


rm -rf deb
mkdir deb
cd deb
CWD=$(pwd)

for f in clickhouse-client_19.7.5.27_all.deb clickhouse-common-static_19.7.5.27_amd64.deb clickhouse-server_19.7.5.27_all.deb; do wget http://repo.yandex.ru/clickhouse/deb/stable/main/$f; done
wget https://dl.grafana.com/oss/release/grafana_6.3.5_amd64.deb
wget https://nginx.org/packages/mainline/ubuntu/pool/nginx/n/nginx/nginx_1.15.10-1~xenial_amd64.deb

cd $(dirname $CWD)

rm -rf packages
mkdir packages
cd packages
CWD=$(pwd)

wget https://github.com/prometheus/node_exporter/releases/download/v0.18.1/node_exporter-0.18.1.linux-amd64.tar.gz
tar xzf node_exporter-0.18.1.linux-amd64.tar.gz
rm -rf node_exporter-0.18.1.linux-amd64.tar.gz
wget https://get.enterprisedb.com/postgresql/postgresql-10.10-1-linux-x64-binaries.tar.gz
tar xzf postgresql-10.10-1-linux-x64-binaries.tar.gz
rm -rf postgresql-10.10-1-linux-x64-binaries.tar.gz
mv -f pgsql pgsql-10
wget https://github.com/prometheus/prometheus/releases/download/v2.12.0/prometheus-2.12.0.linux-amd64.tar.gz
tar xzf prometheus-2.12.0.linux-amd64.tar.gz
rm -rf prometheus-2.12.0.linux-amd64.tar.gz
wget https://github.com/percona/pmm-server/archive/v2.0.0.tar.gz
tar xzf v2.0.0.tar.gz
rm -rf v2.0.0.tar.gz
wget https://github.com/percona/grafana-dashboards/archive/v2.0.0.tar.gz
tar xzf v2.0.0.tar.gz
rm -rf v2.0.0.tar.gz

cd $(dirname $CWD)

