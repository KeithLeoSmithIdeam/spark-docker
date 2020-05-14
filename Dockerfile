#
# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

FROM openjdk:8-jdk-slim

ARG SPARK_VERSION=2.4.5
ARG HADOOP_VERSION=2.7
ARG spark_jars=jars
ARG HDP_VERSION=3.0.1.0-187
ARG PYSPARK_VERSION_FILE=pyspark_hwc-1.0.0.3.0.1.0-187.zip

# Before building the docker image, first build and make a Spark distribution following
# the instructions in http://spark.apache.org/docs/latest/building-spark.html.

RUN set -ex && \
    apt-get update && \
    ln -s /lib /lib64 && \
    apt install -y bash tini libc6 libpam-modules libnss3 wget && \
    mkdir -p /opt/spark && \
    mkdir -p /opt/spark/work-dir && \
    touch /opt/spark/RELEASE && \
    rm /bin/sh && \
    ln -sv /bin/bash /bin/sh && \
    echo "auth required pam_wheel.so use_uid" >> /etc/pam.d/su && \
    chgrp root /etc/passwd && chmod ug+rw /etc/passwd && \
    rm -rf /var/cache/apt/*

WORKDIR /tmp
RUN wget https://archive.apache.org/dist/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz \
    && tar -xvzf spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz \ 
    && cp -r spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}/* /opt/spark/ \
    && rm -f spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz \
    && rm -rf spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}

ENV SPARK_HOME /opt/spark

#ARG JARSDIR=/opt/spark/jars/
#ADD http://repo.hortonworks.com/content/repositories/releases/com/hortonworks/hive/hive-warehouse-connector_2.11/1.0.0.3.0.1.5-3/hive-warehouse-connector_2.11-1.0.0.3.0.1.5-3.jar $JARSDIR
# COPY hwc/hive-warehouse-connector_2.11-1.0.0.3.0.1.0-187.jar $SPARK_HOME/jars/
#COPY hwc/${PYSPARK_VERSION_FILE} /opt/spark/python/
# COPY hwc/${PYSPARK_VERSION_FILE} $SPARK_HOME/python/lib/

RUN apt install -y python python-pip && \
    apt install -y python3 python3-pip && \
    # We remove ensurepip since it adds no functionality since pip is
    # installed on the image and it just takes up 1.6MB on the image
    rm -r /usr/lib/python*/ensurepip && \
    pip install --upgrade pip setuptools && \
    # You may install with python3 packages by using pip3.6
    # Removed the .cache to save space
    rm -r /root/.cache && rm -rf /var/cache/apt/* && \
    rm /usr/bin/python && \
    ln -s /usr/bin/python3.7 /usr/bin/python

ENV PYTHONPATH ${SPARK_HOME}/python/lib/pyspark.zip:${SPARK_HOME}/python/lib/py4j-*.zip

WORKDIR /opt/spark/work-dir

ENTRYPOINT [ "/opt/spark/kubernetes/dockerfiles/spark/entrypoint.sh" ]