#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

#/ Usage:       review_results.sh path/to/baseline.json path/to/otel.json 200
#/ Description: A script to reviewing and failing if we go over our performance budget
#/ Options:     
#/   --help: Display this help message
usage() { grep '^#/' "$0" | cut -c4- ; exit 0 ; }
expr "$*" : ".*--help" > /dev/null && usage

echoerr() { printf "%s\n" "$*" >&2 ; }
info()    { echoerr "[INFO]    $*" ; }
warning() { echoerr "[WARNING] $*" ; }
error()   { echoerr "[ERROR]   $*" ; }
fatal()   { echoerr "[FATAL]   $*" ; exit 1 ; }

if [[ "${BASH_SOURCE[0]}" = "$0" ]]; then
  BASELINE_FILE=$1
  OTEL_FILE=$2
  BUDGET=$3

  info "Starting performance review..."

  fails_baseline=$(cat ${BASELINE_FILE} | jq -r .root_group.checks.ok.fails)
  fails_otel=$(cat ${OTEL_FILE} | jq -r .root_group.checks.ok.fails)

  # Convert to integer.
  fails_baseline=${fails_baseline%.*}
  fails_otel=${fails_otel%.*}

  if (( $fails_baseline > 5 )); then
    fatal "Too many checks failed in the baseline performance test ($fails_baseline)"
  fi

  if (( $fails_otel > 5 )); then
    fatal "Too many checks failed in the opentelemetry performance test ($fails_otel)"
  fi

  http_req_duration_baseline=$(cat ${BASELINE_FILE} | jq -r .metrics.http_req_duration.avg)
  http_req_duration_otel=$(cat ${OTEL_FILE} | jq -r .metrics.http_req_duration.avg)

  # Convert to integer.
  http_req_duration_baseline=${http_req_duration_baseline%.*}
  http_req_duration_otel=${http_req_duration_otel%.*}

  info "http_req_duration = ${http_req_duration_baseline}"
  info "http_req_duration with otel enabled= ${http_req_duration_otel}"

  if (( $http_req_duration_baseline > $http_req_duration_otel )); then
    fatal "OpenTelemetry is more performant than with it off. This cannot be! See output above for stats."
  fi

  http_req_duration_diff=`expr $http_req_duration_otel - $http_req_duration_baseline`

  info "http_req_duration diff = ${http_req_duration_diff}"

  if (( $http_req_duration_diff > $BUDGET )); then
    fatal "We have failed our performance budget (${http_req_duration_diff} > ${BUDGET})"
  fi
fi
