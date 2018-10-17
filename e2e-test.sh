#!/usr/bin/env bash

. ./ci-scripts/build-functions.sh

./start.sh

assert_http_get_response http://localhost:6565 400
assert_http_get_response http://localhost:6565/?version 400
assert_http_get_response http://localhost:6565/ping 200
assert_http_get_response http://localhost:6565/validate 400
assert_http_output http://localhost:6565 "Bad Request"

assert_http_post_response "http://localhost:6565/validate" 200 "$(cat _fixtures/document/product.json)"
assert_http_post_response "http://localhost:6565/validate" 422 "$(cat _fixtures/document/product-invalid.json)"

./stop.sh
