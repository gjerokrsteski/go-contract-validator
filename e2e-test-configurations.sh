#!/usr/bin/env bash

. ./ci-scripts/build-functions.sh

./dist/contract-validator-amd64-linux -jsonSchema=file://${PWD}/_fixtures/schema/configuration.json & echo $! > ./pidfile_configurations

assert_http_post_response "http://localhost:6565/validate" 200 "$(cat _fixtures/document/configuration.json)"
assert_http_post_response "http://localhost:6565/validate" 422 "$(cat _fixtures/document/configuration-invalid.json)"

kill -15 $(cat ./pidfile_configurations)
