#!/bin/bash
VERBOSITY="0"
while (( "$#" )); do
  case "$1" in
    -v|--verbosity)
      VERBOSITY=$2
      if [[ $VERBOSITY == -* || ! $VERBOSITY ]]; then
          # next parameter is not the verbosity number, so just set to 1
          VERBOSITY="1"
          shift
      else
          VERBOSITY=$2
          shift 2
      fi
      ;;
    *) # preserve positional arguments
      PARAMS="$PARAMS $1"
      shift
      ;;
  esac
done
