#!/usr/bin/env bash

date_format="+%Y-%m-%d_%H-%M-%S%z"

print_info() {
  echo -e "$(date ${date_format}) ### INFO - $1"
}

print_warn() {
  echo -e "$(date ${date_format}) ### WARN - $1"
}

print_error() {
  echo -e "$(date ${date_format}) ### ERROR - $1" | STDERR
}

assert_error() {
  print_error "$1"
  exit 1
}

function STDERR () {
    cat - 1>&2
}

assert_not_empty_string() {
  if [[ -z $1 ]]; then
    assert_error $2
  fi
}

assert_file_exists() {
  if [[ ! -e $1 ]]; then
    assert_error "Could not find file: \"${1}\""
  fi
}

assert_exit_code() {
  local exit_code=$?
  if [[ ${exit_code} -ne 0 ]]; then
    assert_error "$1 (exit code: ${exit_code})"
  fi
}

assert_remote_json_element(){
    local remoteUrl=$1
    local jsonSelector=$2
    local expectedValue=$3
    local fetchedValue=$(curl --silent "${remoteUrl}" | jq ${jsonSelector})

    if [ "$fetchedValue" != "$expectedValue" ]; then
      assert_error "fetched-value is '$fetchedValue' expected value of '$expectedValue' for json-selector '$jsonSelector' not found!"
    fi

    print_info "fetched-value is '$fetchedValue' same expected value of '$expectedValue'"
}

assert_if_not_expected(){
    local expectedValue=$2
    local fetchedValue=$1

    if [ "$fetchedValue" != "$expectedValue" ]; then
      assert_error "fetched-value is '$fetchedValue' expected value of '$expectedValue' not found!"
    fi

     print_info "fetched-value is '$fetchedValue' same expected value of '$expectedValue'"
}

assert_http_get_response(){
    if [[ -z "$1" ]]; then
     echo -e "The script checks if given URI (Uniform Resource Identifier) is responding HTTP status code 200\n
     URI = http(s)://example.com:8042/over/there?name=ferret#nose
            \_____/\_________________/\_________/\_________/\__/
                |           |               |         |      |
             scheme     authority          path     query  fragment
                |   ________________________|__
               / \ /                           \\
               urn:example:animal:ferret:nose\n"
      echo "Usage: assert_http_get_response <URI> <EXPECTED HTTP CODE>"
     exit 1
    fi

    if [[ -z "$2" ]]; then
     assert_error "No expected http code given! Usage: assert_http_response <URI> <EXPECTED HTTP CODE>"
    fi

    local expectedHttpCode=$2
    local testHttpCode=$(curl --silent -sL -w '%{http_code}' $1 -o /dev/null 2>&1 | grep ${expectedHttpCode})

    if [ "$testHttpCode" != "${expectedHttpCode}" ]; then
      assert_error "no HTTP status code ${expectedHttpCode} received!"
    fi

    print_info "HTTP status code ${expectedHttpCode} received"
}

assert_http_post_response(){
    if [[ -z "$1" ]]; then
     echo -e "The script checks if given URI (Uniform Resource Identifier) is responding HTTP status code 200\n
     URI = http(s)://example.com:8042/over/there?name=ferret#nose
            \_____/\_________________/\_________/\_________/\__/
                |           |               |         |      |
             scheme     authority          path     query  fragment
                |   ________________________|__
               / \ /                           \\
               urn:example:animal:ferret:nose\n"
      echo "Usage: assert_http_post_response <URI> <EXPECTED HTTP CODE> <DATA TO BE SEND>"
     exit 1
    fi

    if [[ -z "$2" ]]; then
     assert_error "No expected http code given! Usage: assert_http_response <URI> <EXPECTED HTTP CODE>"
    fi

    local expectedHttpCode=$2
    local data=$3
    local testHttpCode=$(curl --silent -X POST -H "Content-Type: text/plain" --data "${data}" -sL -w '%{http_code}' $1 -o /dev/null 2>&1 | grep ${expectedHttpCode})

    if [ "$testHttpCode" != "${expectedHttpCode}" ]; then
      assert_error "no HTTP status code ${expectedHttpCode} received!"
    fi

    print_info "HTTP status code ${expectedHttpCode} received"
}

assert_http_output(){
    if [[ -z "$1" || -z "$2"  ]]; then
     assert_error "The script checks the application's HTTP output. Usage: assert_http_output <URI> <EXPECTED STRING>"
    fi

    local URI=$1
    local EXPECTED_STRING=$2

    sleep 1

    print_info "CHECK if expected string \"${EXPECTED_STRING}\" is at HTTP output"

    if curl --silent ${URI} | grep -q "${EXPECTED_STRING}"; then
      print_info "expected string \"${EXPECTED_STRING}\" was found at HTTP output."
    else
      assert_error "expected string \"${EXPECTED_STRING}\" was not found at HTTP output."
    fi
}
