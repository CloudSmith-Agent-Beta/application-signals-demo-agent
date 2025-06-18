#!/usr/bin/env bash

# Initialize variables
export VISITS_FILE=spring-petclinic-visits-service/src/main/java/org/springframework/samples/petclinic/visits/web/VisitResource.java
trigger_flag=false
rollback_flag=false
error=false

# Function to display usage information
usage() {
    echo "Usage: $0 trigger | rollback"
    echo "Note: Exactly one flag must be specified."
}

# Check if no arguments were provided
if [ $# -eq 0 ]; then
    echo "Error: No flags provided."
    usage
    exit 1
fi

# Parse command line arguments
while [ $# -gt 0 ]; do
    case "$1" in
        trigger)
            trigger_flag=true
            shift
            ;;
        rollback)
            rollback_flag=true
            shift
            ;;
        *)
            error=true
            shift
            ;;
    esac
done

# Check if both flags are provided
if $trigger_flag && $rollback_flag; then
    echo "Error: Both trigger and rollback flags were provided."
    usage
    exit 1
fi

# Check if neither flag is provided (should be caught by the first check, but just to be safe)
if ! $trigger_flag && ! $rollback_flag; then
    echo "Error: Neither trigger nor rollback flag was provided."
    usage
    exit 1
fi

# Check if there was an error with the arguments
if $error; then
    usage
    exit 1
fi

# Execute based on the flag provided
if $trigger_flag; then
    echo "Triggering alarm2 ..."
    git checkout trigger-alarm2 -- ${VISITS_FILE}
    git add ${VISITS_FILE}
    git commit -m "feat: update visits service with new memory implementation"
    git push
elif $rollback_flag; then
    echo "Rolling back alarm2 ..."
    git checkout revert-alarm2 -- ${VISITS_FILE}
    git add ${VISITS_FILE}
    git commit -m "revert: rollback bad memory code in visits service"
    git push
fi

exit 0