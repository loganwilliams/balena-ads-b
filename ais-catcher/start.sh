#!/usr/bin/env bash
set -e

# Check if service has been disabled through the DISABLED_SERVICES environment variable.

if [[ ",$(echo -e "${DISABLED_SERVICES}" | tr -d '[:space:]')," = *",$BALENA_SERVICE_NAME,"* ]]; then
        echo "$BALENA_SERVICE_NAME is manually disabled. Sending request to stop the service:"
        curl --header "Content-Type:application/json" "$BALENA_SUPERVISOR_ADDRESS/v2/applications/$BALENA_APP_ID/stop-service?apikey=$BALENA_SUPERVISOR_API_KEY" -d '{"serviceName": "'$BALENA_SERVICE_NAME'"}'
        echo " "
        balena-idle
fi

# Verify that all the required variables are set before starting up the application.

echo "Verifying settings..."
echo " "
sleep 2

# Begin defining all the required configuration variables.

[ -z "$MT_PORT" ] && echo "Marine Traffic port is missing, will abort startup." && missing_variables=true || echo "Marine Traffic port is set: $MT_PORT"

# End defining all the required configuration variables.

echo " "

# Start fr24feed and put it in the background.
/usr/local/bin/AIS-catcher -d 00000002 -q -N 8100 LAT $LAT LON $LON SHARE_LOC on -u 5.9.207.224 $MT_PORT -u 195.201.71.220 $VF_PORT &

# Wait for any services to exit.
wait -n