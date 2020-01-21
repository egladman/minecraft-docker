#!/bin/bash

# M_* denotes Minecraft
M_FORGE_VERSION="${1}"
M_MANIFEST_JSON_PATH="manifest.json"
M_FORGE_DOWNLOAD_URL=""
M_FORGE_DOWNLOAD_SHA256SUM=""
M_FORGE_INSTALLER_JAR=""

# CLR_* denotes Color
CLR_RED="\033[0;31m"
CLR_NONE="\033[0m"

# Helpers
_log() {
    echo -e ${0##*/}: "${@}" 1>&2
}

_die() {
    _log "${CLR_RED}FATAL:${CLR_NONE} ${@}"
    exit 1
}

_validate_semver() {
    local SEMANTIC_VERSION="${1}"
    if [[ ! "${SEMANTIC_VERSION}" =~ ^[0-9]+(\.[0-9]+){2,3}$ ]]; then
        _die "\"${SEMANTIC_VERSION}\" isn't a valid semantic version."
    fi
}

_compare_checksum() {
    local TARGET_FILE="${1}"
    local CHECKSUM_ACTUAL="$(sha256sum ${TARGET_FILE} | cut -d' ' -f1)"
    local CHECKSUM_DESIRED="${2}"

    if [ "${CHECKSUM_ACTUAL}" != "${CHECKSUM_DESIRED}" ]; then
        _die "Checksum doesn't match for file: ${TARGET_FILE}. Expected: ${CHECKSUM_DESIRED}. Got: ${CHECKSUM_ACTUAL}."
    fi
}

if [ -n "${M_FORGE_VERSION}" ]; then
    _validate_semver "${M_FORGE_VERSION}"
else
    _die "First argument missing. Must specify FORGE VERSION"
fi

M_FORGE_DOWNLOAD_URL=$(jq --raw-output --arg _semver "${M_FORGE_VERSION}" '.["java-edition"][].custom.forge[] | select(.version == $_semver) | .url' "${M_MANIFEST_JSON_PATH}")
if [ "${?}" -ne 0 ]; then
    _die "Unable to determine forge download url. jq exited with nonzero status."
fi

M_FORGE_DOWNLOAD_SHA256SUM=$(jq --raw-output --arg _semver "${M_FORGE_VERSION}" '.["java-edition"][].custom.forge[] | select(.version == $_semver) | .sha256' "${M_MANIFEST_JSON_PATH}")
if [ "${?}" -ne 0 ]; then
    _die "Unable to determine forge download sha256sum. jq exited with nonzero status."
fi

wget "${M_FORGE_DOWNLOAD_URL}" || _die "Failed to fetch ${M_FORGE_DOWNLOAD_URL}"

M_FORGE_INSTALLER_JAR="$(basename ${M_FORGE_DOWNLOAD_URL})"
_compare_checksum "${M_FORGE_INSTALLER_JAR}" "${M_FORGE_DOWNLOAD_SHA256SUM}"
