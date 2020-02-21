#! /bin/bash

function fatal_error()
{
  echo "$0: FATAL_ERROR: $1" >&2
  exit 1
}

# Lock fd $2.
# <unique_key> is usually a PID.

if [ $# -ne 2 -o ! -d "$1" ]; then
  echo "Usage: $0 <directory> <unique_key>" >&2
  exit 1
else
  echo "-- Locking directory \"$1\"."
  (
    while true; do
      flock 9 || fatal_error "Couldn't lock \"$1/gitache.flock\"!?!" 

      if [ -e "$1/gitache.lock" ]; then
        KEY=$(cat "$1/gitache.lock")
        test "$KEY" != "$2" || fatal_error "Calling lock recursively ($2)?!"
        echo "** Can't lock \"$1\" with key '$2' because \"$1/gitache.lock\" already exists ($KEY). Sleeping 1 second..."
        flock -u 9
        sleep 1
        continue
      fi

      echo "$2" > "$1/gitache.lock" || fatal_error "Failed to write to \"$1/gitache.lock\""
      break;
    done

  ) 9>"$1/gitache.flock"
fi