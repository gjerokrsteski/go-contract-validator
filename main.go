package main

import (
	"fmt"
	"github.com/santhosh-tekuri/jsonschema"
	"net/http"
	"encoding/json"
	"os"
	"io"
	"flag"
	"log"
	"io/ioutil"
	"strings"
)

var Version string = "No Version Provided"
var jsonSchema string
var serviceName string = "HTTP service for validating JSON entities by given JSON Schema"
var servicePort string

//main handles the cli flags and starts an HTTP server by given port.
func main() {
	flag.StringVar(&servicePort, "port", "6565", "port number to the host")
	flag.StringVar(&jsonSchema, "jsonSchema", "./", "absolute path to JSON schema file")
	version := flag.Bool("version", false, "prints current version")
	flag.Parse()

	if *version {
		fmt.Println("v" + Version + " of " + serviceName)
		os.Exit(0)
	}

	//define the HTTP multiplexer request routes and its handlers.
	http.HandleFunc("/validate", handleValidation)
	http.HandleFunc("/ping", handlePing)
	http.HandleFunc("/", handleHome)

	log.Print("starting " + serviceName + " v" + Version + " on port: " + servicePort + " using JSON schema: " + jsonSchema)

	err := http.ListenAndServe(":"+servicePort, nil)
	if err != nil {
		log.Fatal("ListenAndServe: ", err)
	}
}

//handlePing returns a information about running service in the response body as JSON sting.
func handlePing(responseWriter http.ResponseWriter, request *http.Request) {
	pingInfo := map[string]string{"service": serviceName, "port": servicePort, "jsonSchemaFile": jsonSchema, "version": Version}
	pingInfoMap, _ := json.Marshal(pingInfo)
	responseWriter.Header().Set("Content-Type", "application/json")
	io.WriteString(responseWriter, string(pingInfoMap))
}

//handleHome returns a BadRequest HTTP status and information as string about how to use the main service.
func handleHome(responseWriter http.ResponseWriter, request *http.Request) {
	responseWriter.WriteHeader(http.StatusBadRequest)
	io.WriteString(responseWriter, "Bad Request! Send JSON data at body using route '/validate'\n")
}

//handleValidation responds a StatusUnprocessableEntity if the JSON data is not valid and
//responds StatusOK if JSON data is valid.
func handleValidation(responseWriter http.ResponseWriter, request *http.Request) {
	request.ParseForm()

	body, err := ioutil.ReadAll(request.Body)
	if err != nil {
		responseWriter.WriteHeader(http.StatusUnprocessableEntity)
		io.WriteString(responseWriter, "Unprocessable Entity! "+err.Error()+"\n")
		return
	}

	jsonToValidate := strings.TrimSpace(string(body))
	if jsonToValidate == "" {
		responseWriter.WriteHeader(http.StatusBadRequest)
		io.WriteString(responseWriter, "Bad Request! No JSON data at HTTP request found.\n")
		return
	}

	result, err := jsonschema.Compile(jsonSchema)
	if err != nil {
		responseWriter.WriteHeader(http.StatusUnprocessableEntity)
		io.WriteString(responseWriter, "Unprocessable Entity! Invalid JSON schema. "+err.Error()+"\n")
		return
	}

	err = result.Validate(strings.NewReader(jsonToValidate))
	if err != nil {
		responseWriter.WriteHeader(http.StatusUnprocessableEntity)
		io.WriteString(responseWriter, "Unprocessable Entity! "+err.Error()+"\n")
		return
	}

	responseWriter.WriteHeader(http.StatusOK)
}
