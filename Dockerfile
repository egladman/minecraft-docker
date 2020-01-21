FROM alpine:latest

# TODO: Move enviroment variable declaration to docker-compose.yml
ENV MC_FORGE_VERSION 27.0.25
ENV MC_USER minecraft
ENV MC_MIN_HEAP_SIZE 1024M
ENV MC_MAX_HEAP_SIZE 2048M
ENV MC_SERVER_INSTANCE_DIR /opt/minecraft
ENV MC_SERVER_INSTANCE_PIPE minecraft.fifo
ENV SYS_JAVA_PATH /usr/bin/java

# Using "--no-cache" instead of "apk update"
# to keep the overall size of the image as small as possible
RUN apk add --no-cache openjdk8-jre jq bash

# Create unprivileged user
RUN addgroup -S "${MC_USER}"
RUN adduser -S -G "${MC_USER}" "${MC_USER}" # Create system user add to group: MC_USER

RUN mkdir -p "${MC_SERVER_INSTANCE_DIR}"
COPY . "${MC_SERVER_INSTANCE_DIR}"

WORKDIR "${MC_SERVER_INSTANCE_DIR}"
RUN ./utils/fetchRelease.sh "${MC_FORGE_VERSION}"
RUN MC_FORGE_INSTALLER_JAR="$(find forge-*-installer.jar -type f -print0)"; \
    "${SYS_JAVA_PATH}" -verbose -jar "${MC_SERVER_INSTANCE_DIR}"/"${MC_FORGE_INSTALLER_JAR}" --installServer && \
    rm -rf "${MC_FORGE_INSTALLER_JAR}"

# Accept EULA
RUN ./utils/eula.sh

RUN chown -R "${MC_USER}":"${MC_USER}" "${MC_SERVER_INSTANCE_DIR}" 
USER "${MC_USER}"
CMD "${MC_SERVER_INSTANCE_DIR}"/bin/start

# Default minecraft port
EXPOSE 25565