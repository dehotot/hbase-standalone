#  vim:ts=4:sts=4:sw=4:et

FROM alpine:latest
MAINTAINER Alex White (alex.white@diamond.ac.uk)

ARG HBASE_VERSION=1.2.6

ENV PATH $PATH:/hbase/bin

ENV JAVA_HOME=/usr

LABEL Description="HBase Dev", \
      "HBase Version"="$HBASE_VERSION"

WORKDIR /

# bash => entrypoint.sh
# java => hbase engine
RUN set -euxo pipefail && \
    apk add --no-cache bash openjdk8-jre-base

COPY bin/hbase-$HBASE_VERSION-bin.tar.gz /

RUN set -euxo pipefail && \
    apk add --no-cache tar && \
    mkdir "hbase-$HBASE_VERSION" && \
    tar zxf "hbase-$HBASE_VERSION-bin.tar.gz" -C "hbase-$HBASE_VERSION" --strip 1 && \
    test -d "hbase-$HBASE_VERSION" && \
    ln -sv "hbase-$HBASE_VERSION" hbase && \
    rm -fv "hbase-$HBASE_VERSION-bin.tar.gz" && \
    { rm -rf hbase/{docs,src}; : ; } && \
    mkdir /hbase-data && \
    apk del tar

VOLUME /hbase-data

COPY start-hmaster.sh       /
COPY start-regionserver.sh  /
COPY conf/hbase-site.xml    /hbase/conf/
COPY conf/regionservers     /hbase/conf/
COPY profile.d/java.sh      /etc/profile.d/

COPY opentsdb-setup         /

EXPOSE 2181 16000 16010 16020 16030
