# The following MUST be passed in as environment variables.
# - MC_SERVER_INSTANCE_DIR

if [ -z "${MC_SERVER_INSTANCE_DIR}" ]; then
    echo "MC_* environment variables not defined. Dying..."
    exit 1
fi

MC_SERVER_JAR="$(find minecraft_server*.jar -type f -print0)" # Since the .jar name can vary we must dynamically find it
# TODO: Check if there is more than one .jar in the directory, if so gracefully fail. just to be safe...

# We have to manually run the .jar instead of using the bin/start wrapper script
# Since it's configured to tail a named pipe.
${SYS_JAVA_PATH} -jar ${MC_SERVER_INSTANCE_DIR}/${MC_SERVER_JAR} && {
    # When executed for the first time, the jar will generate eula.txt and exit. We need to accept the EULA
    while [ ! -f "${MC_SERVER_INSTANCE_DIR}/eula.txt" ]
    do
        sleep 1 # Check every 1 second to see if the eula.txt has been generated yet
    done

    echo "eula.txt found! Accepting end user license agreement"
    sed -i -e 's/false/true/' "${MC_SERVER_INSTANCE_DIR}/eula.txt" || _die "Failed to modify ${MC_SERVER_INSTANCE_DIR}/eula.txt".
} || echo "Failed to execute ${MC_SERVER_INSTANCE_DIR}/bin/start for the first time."
