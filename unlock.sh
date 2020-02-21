#! /bin/bash

function fatal_error()
{
  echo "$0: FATAL_ERROR: $1" >&2
  exit 1
}

# Unlock directory $1.
# <unique_key> is usually a PID.

if [ $# -ne 2 -o ! -d "$1" ]; then
  echo "Usage: $0 <directory> <unique_key>" >&2
  exit 1
else
  echo "-- Unlocking directory \"$1\"."
  (
  flock 9 || fatal_error "Couldn't lock \"$1/gitache.flock\" ($2)!?!" 

    [ -f "$1/gitache.lock" ] || fatal_error "Calling unlock \"$1\" while not not being locked!?!"
    KEY=$(cat "$1/gitache.lock")
    test "$KEY" = "$2" || fatal_error "Calling unlock \"$1\" with key '$2', but directory is locked by '$KEY' !!"
    rm "$1/gitache.lock" || fatal_error "Failed to remove to \"$1/gitache.lock\"!?!"

  ) 9>"$1/gitache.flock"
fi
