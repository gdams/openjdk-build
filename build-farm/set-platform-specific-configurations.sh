#!/bin/bash
# shellcheck disable=SC1090,SC1091
# ********************************************************************************
# Copyright (c) 2024 Contributors to the Eclipse Foundation
#
# See the NOTICE file(s) where distributed with this work for additional
# information regarding copyright ownership.
#
# This program and the accompanying materials are made
# available under the terms of the Apache Software License 2.0
# which is available at https://www.apache.org/licenses/LICENSE-2.0.
#
# SPDX-License-Identifier: Apache-2.0
# ********************************************************************************

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
# shellcheck source=sbin/common/constants.sh
source "$SCRIPT_DIR/../sbin/common/constants.sh"

if [ "${JAVA_TO_BUILD}" != "${JDK8_VERSION}" ]
then
    export CONFIGURE_ARGS_FOR_ANY_PLATFORM="${CONFIGURE_ARGS_FOR_ANY_PLATFORM} --disable-warnings-as-errors"
fi

export VARIANT_ARG="--build-variant ${VARIANT}"

# If a user file doesn't exist, pull from an online source. To always pull from an online source, ensure platform config files have been deleted from your local clone.
PLATFORM_CONFIG_FILEPATH="$SCRIPT_DIR/platform-specific-configurations/${OPERATING_SYSTEM}.sh"
if [ ! -f "${PLATFORM_CONFIG_FILEPATH}" ]
then
    # Fail build if a local file doesn't exist and network location hasn't been set
    if [ -z "${PLATFORM_CONFIG_LOCATION}" ]
    then
        echo "[ERROR] No local file detected at ${PLATFORM_CONFIG_FILEPATH} and PLATFORM_CONFIG_LOCATION is not set. Please set PLATFORM_CONFIG_LOCATION to a repository path of a platform config file (e.g. adoptium/temurin-build/master/build-farm/platform-specific-configurations)."
        exit 3
    fi

    # Create placeholders for curl --output
    if [ ! -d "$SCRIPT_DIR/platform-specific-configurations" ]
    then
        mkdir "$SCRIPT_DIR/platform-specific-configurations"
    fi

    # Reset config file to execute
    rm -f "$SCRIPT_DIR/platform-specific-configurations/platformConfigFile.sh"
    touch "$SCRIPT_DIR/platform-specific-configurations/platformConfigFile.sh"

    PLATFORM_CONFIG_FILEPATH="$SCRIPT_DIR/platform-specific-configurations/platformConfigFile.sh"

    # Setup for platform config download
    rawGithubSource="https://raw.githubusercontent.com"
    ret=0
    fileContents=""

    # Uses curl to download the platform config file
    # param 1: LOCATION - Repo path to where the file is located
    # param 2: SUFFIX - Operating system to append
    function downloadPlatformConfigFile () {
        echo "Attempting to download platform configuration file from ${rawGithubSource}/$1/$2"
        # make-adopt-build-farm.sh has 'set -e'. We need to disable that for the fallback mechanism, as downloading might fail
        set +e
        curl "${rawGithubSource}/$1/$2" > "${PLATFORM_CONFIG_FILEPATH}"
        ret=$?
        # A download will succeed if location is a directory, so we also check the contents are valid
        fileContents=$(cat "$PLATFORM_CONFIG_FILEPATH")
        set -e
    }

    # Attempt to download and source the user's custom platform config
    downloadPlatformConfigFile "${PLATFORM_CONFIG_LOCATION}" ""
    # Regex to spot github api error messages similar to "404: Not Found"
    contentsErrorRegex="#!/bin/bash"

    if [ $ret -ne 0 ] || [[ ! $fileContents =~ $contentsErrorRegex ]]
    then
        # Check to make sure that a OS file doesn't exist if we can't find a config file from the direct link
        echo "[WARNING] Failed to find a user configuration file, ${rawGithubSource}/${PLATFORM_CONFIG_LOCATION} is likely a directory so we will try and search for a ${OPERATING_SYSTEM}.sh file."
        downloadPlatformConfigFile "${PLATFORM_CONFIG_LOCATION}" "${OPERATING_SYSTEM}.sh"

        if [ $ret -ne 0 ] || [[ ! $fileContents =~ $contentsErrorRegex ]]
        then
            # If there is no user platform config, use Adoptium's as a default instead
            echo "[WARNING] Failed to download a user platform configuration file. Downloading Adoptium's ${OPERATING_SYSTEM}.sh configuration file instead."
            downloadPlatformConfigFile "${ADOPT_PLATFORM_CONFIG_LOCATION}" "${OPERATING_SYSTEM}.sh"

            if [ $ret -ne 0 ] || [[ ! $fileContents =~ $contentsErrorRegex ]]
            then
                echo "[ERROR] Failed to download a platform configuration file from User and Adoptium's repositories"
                exit 2
            fi
        fi
    fi

    echo "[SUCCESS] Config file downloaded successfully to ${PLATFORM_CONFIG_FILEPATH}"
else
    echo "[SUCCESS] Executing local file at ${PLATFORM_CONFIG_FILEPATH}"
fi
source "${PLATFORM_CONFIG_FILEPATH}"
