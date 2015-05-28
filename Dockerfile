FROM ubuntu:14.04

RUN mkdir /app
WORKDIR /app

# Add repos and update
RUN apt-get install -y apt-transport-https &&\
    echo "deb https://packagecloud.io/grafana/stable/debian/ wheezy main" | tee -a /etc/apt/sources.list &&\
    apt-get install -y curl &&\
    curl https://packagecloud.io/gpg.key | apt-key add - &&\
    apt-get update

# Install supervisor
RUN apt-get install -y supervisor
ADD supervisord.conf /app/supervisord.conf

# Install influx
RUN apt-get install -y wget &&\
    wget https://s3.amazonaws.com/influxdb/influxdb_0.8.8_amd64.deb &&\
    dpkg -i influxdb_0.8.8_amd64.deb

# Install statsd
RUN apt-get install -y nodejs &&\
    apt-get install -y npm &&\
    apt-get install -y git
RUN git clone https://github.com/etsy/statsd.git
WORKDIR /app/statsd
RUN git checkout v0.7.2
RUN npm install -y statsd-influxdb-backend
ADD statsd-config.js /app/statsd/config.js

WORKDIR /app

# Install grafana
RUN apt-get install -y grafana=2.0.2

# Grafana web
EXPOSE 3000
# Statsd
EXPOSE 8125
# InfluxDB web
EXPOSE 8083
# InfluxDB api
EXPOSE 8086


CMD ["/usr/bin/supervisord", "-c", "/app/supervisord.conf"]
