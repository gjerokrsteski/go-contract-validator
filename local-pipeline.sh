#!/usr/bin/env bash
set -e
. ./ci-scripts/build-functions.sh

./install.sh
assert_exit_code "ERROR installing go dependencies"

./lint-go.sh
assert_exit_code "ERROR linting"

./build.sh
assert_exit_code "ERROR building"

./e2e-test.sh
assert_exit_code "ERROR e2e testing"

./e2e-test-registrations.sh
assert_exit_code "ERROR e2e testing of registrations schema"

./e2e-test-configurations.sh
assert_exit_code "ERROR e2e testing of configurations schema"

print_info "successful!"
