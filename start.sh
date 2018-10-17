#!/bin/sh
set -e
((./dist/contract-validator-amd64-linux -jsonSchema=file://${PWD}/_fixtures/schema/product.json) & echo $! > ./pidfile)
