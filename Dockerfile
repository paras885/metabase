###################
# STAGE 1: builder
###################

FROM node:16-slim as builder

ARG MB_EDITION=oss

WORKDIR /home/node

RUN apt-get update && apt-get upgrade -y && apt-get install curl git -y \
    && curl -O https://download.clojure.org/install/linux-install-1.11.1.1262.sh \
    && chmod +x linux-install-1.11.1.1262.sh \
    && ./linux-install-1.11.1.1262.sh

# Install OpenJDK 8 from AdoptOpenJDK
RUN curl -L -O https://github.com/AdoptOpenJDK/openjdk8-binaries/releases/download/jdk8u292-b10/OpenJDK8U-jdk_x64_linux_hotspot_8u292b10.tar.gz \
    && tar xzf OpenJDK8U-jdk_x64_linux_hotspot_8u292b10.tar.gz -C /opt \
    && rm OpenJDK8U-jdk_x64_linux_hotspot_8u292b10.tar.gz

# Set JAVA_HOME environment variable
ENV JAVA_HOME=/opt/jdk8u292-b10

COPY . .

# version is pulled from git, but git doesn't trust the directory due to different owners
RUN git config --global --add safe.directory /home/node

RUN INTERACTIVE=false CI=true MB_EDITION=$MB_EDITION bin/build.sh

# ###################
# # STAGE 2: runner
# ###################

FROM adoptopenjdk:8-jre-hotspot as runner

ENV FC_LANG en-US LC_CTYPE en_US.UTF-8

# dependencies
RUN apt-get update && apt-get install -y fontconfig curl && \
    mkdir -p /app/certs && \
    curl https://s3.amazonaws.com/rds-downloads/rds-combined-ca-bundle.pem -o /app/certs/rds-combined-ca-bundle.pem  && \
    keytool -noprompt -import -trustcacerts -alias aws-rds -file /app/certs/rds-combined-ca-bundle.pem -keystore /usr/lib/jvm/java-8-openjdk-amd64/jre/lib/security/cacerts -storepass changeit && \
    curl https://cacerts.digicert.com/DigiCertGlobalRootG2.crt.pem -o /app/certs/DigiCertGlobalRootG2.crt.pem  && \
    keytool -noprompt -import -trustcacerts -alias azure-cert -file /app/certs/DigiCertGlobalRootG2.crt.pem -keystore /usr/lib/jvm/java-8-openjdk-amd64/jre/lib/security/cacerts -storepass changeit && \
    mkdir -p /plugins && chmod a+rwx /plugins

# add Metabase script and uberjar
COPY --from=builder /home/node/target/uberjar/metabase.jar /app/
COPY bin/docker/run_metabase.sh /app/

# expose our default runtime port
EXPOSE 3000

# run it
ENTRYPOINT ["/app/run_metabase.sh"]
