#!/bin/bash

# Build a modern version of libpq from source on Centos 5

# work in progress, to be tested entirely

set -e -x

OPENSSL_TAG=OpenSSL_1_0_2k
LDAP_VERSION=2.4.44
POSTGRES_TAG=REL9_6_2

yum install -y zlib-devel krb5-devel pam-devel

wget -O - https://github.com/openssl/openssl/archive/${OPENSSL_TAG}.tar.gz \
	| tar xzvf -
cd "openssl-${OPENSSL_TAG}/"
./config --prefix=/usr/local/ --openssldir=/usr/local/ zlib no-idea no-mdc2 no-rc5 no-ec no-ecdh no-ecdsa shared --with-krb5-flavor=MIT
make depend
make && make install
cd ..

wget -O - ftp://ftp.openldap.org/pub/OpenLDAP/openldap-release/openldap-${LDAP_VERSION}.tgz \
	| tar xzvf -
cd "openldap-${LDAP_VERSION}/"
./configure --enable-backends=no --enable-null
make depend
(cd libraries/liblutil/ && make)
(cd libraries/liblber/ && make && make install)
(cd libraries/libldap/ && make && make install)
(cd libraries/libldap_r/ && make && make install)
(cd include/ && make install)
cd ..

wget -O - https://github.com/postgres/postgres/archive/${POSTGRES_TAG}.tar.gz \
	| tar xzvf -

cd "postgres-${POSTGRES_TAG}/"
./configure --prefix=/usr/local --without-readline \
	--with-gssapi --with-openssl --with-pam --with-ldap
(cd src/interfaces/libpq && make && make install)
(cd src/bin/pg_config && make && make install)
# This will fail after installing postgres_fe.h, which is what we need
(cd src/include && make && make install || true)
cd ..
