#!/bin/sh

# Setting up the proper database
if [ -n "$DATABASE" ]; then
  sed -ie "s/database: cassandra/database: $DATABASE/" /etc/kong/kong.yml
fi

# Postgres
if [ -n "$POSTGRES_HOST" ]; then
  sed -ie "s/host: \"kong-database\"/host: \"$POSTGRES_HOST\"/" /etc/kong/kong.yml
fi

if [ -n "$POSTGRES_PORT" ]; then
  sed -ie "s/port: 5432/port: $POSTGRES_PORT/" /etc/kong/kong.yml
fi

if [ -n "$POSTGRES_DB" ]; then
  sed -ie "s/database: kong/database: $POSTGRES_DB/" /etc/kong/kong.yml
fi

if [ -n "$POSTGRES_USER" ]; then
  sed -ie "s/user: kong/user: $POSTGRES_USER/" /etc/kong/kong.yml
fi

if [ -n "$POSTGRES_PASSWORD" ]; then
  sed -ie "s/#  password: kong/  password: $POSTGRES_PASSWORD/" /etc/kong/kong.yml
fi

# Cassandra
if [ -n "$CASSANDRA_CONTACT_POINTS" ]; then
  sed -ie "s/\"kong-database:9042\"/$CASSANDRA_CONTACT_POINTS/" /etc/kong/kong.yml
fi
if [ -n "$CASSANDRA_KEYSPACE" ]; then
  sed -ie "s/keyspace: kong/keyspace: $CASSANDRA_KEYSPACE/" /etc/kong/kong.yml
fi

if [ -n "$CASSANDRA_USER" ]; then
  sed -ie "s/#  user: cassandra/  user: $CASSANDRA_USER/" /etc/kong/kong.yml
fi

if [ -n "$CASSANDRA_PASSWORD" ]; then
  sed -ie "s/#  password: cassandra/  password: $CASSANDRA_PASSWORD/" /etc/kong/kong.yml
fi

# Cluster Listen
if [ -n "$CLUSTER_LISTEN" ]; then
  if [ "$CLUSTER_LISTEN" = "rancher" ]; then
    CLUSTER_LISTEN="$(curl --retry 3 --fail --silent http://rancher-metadata/2015-07-25/self/container/primary_ip):7946"
  fi
  sed -ie "s/cluster_listen: \"0.0.0.0:7946\"/cluster_listen: \"$CLUSTER_LISTEN\"/" /etc/kong/kong.yml
fi

# SSL

if [ -n "$SSL_CERT" ]; then
  mkdir -p /usr/local/kong/ssl/
  
  echo -e $SSL_CERT >> /usr/local/kong/ssl/server.crt
  echo -e $SSL_KEY >> /usr/local/kong/ssl/server.key

  sed -ie "s/#  ssl_cert_path:/ssl_cert_path/" /etc/kong/kong.yml
  sed -ie "s/#  ssl_key_path:/ssl_key_path/" /etc/kong/kong.yml
fi