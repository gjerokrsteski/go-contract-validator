# contract-validator [![Build Status](https://travis-ci.org/gjerokrsteski/go-contract-validator.svg?branch=master)](https://travis-ci.org/gjerokrsteski/go-contract-validator) [![Go Report Card](https://goreportcard.com/badge/github.com/gjerokrsteski/go-contract-validator)](https://goreportcard.com/report/github.com/gjerokrsteski/go-contract-validator)
A cli app that implements HTTP service for validating JSON entities by given JSON Schema.

The binary is compiled for all Linux distributions which rely on amd64 process-architecture. 
It listens on the TCP network address and then calls Serve with handler to handle requests 
on incoming connections.

## Explorer the service

```
./contract-validator --help

Usage of ./contract-validator:
  -jsonSchema string
        absolute path to JSON schema file (default "./")
  -port string
        port number to the host (default "6565")
  -version
        prints current version

```

## Start the service (default port is 6565)

```
./contract-validator -port=6565 -jsonSchema=file://${PWD}/_fixtures/product-schema.json
```

## Validate JSON data
```
curl -X POST "http://localhost:6565/validate" -d "{"id":1,"name":"A green door","price": 12.50,"tags": ["home", "green"]}"
```
For example you can use `curl` to execute an request to `http://localhost:6565/validate` using HTTP request method `POST` 
and an JSON data as request body.

*Possible responses are:*
- 400 Bad Request: if JSON data is empty.
- 422 Unprocessable Entity: if JSON schema or data are not valid. A list of vulnerabilities is responded within response body.
- 200 OK: if JSON data is valid.

# Development
For developing and contributing you need [Golang 1.9.1](https://golang.org/) installed.
