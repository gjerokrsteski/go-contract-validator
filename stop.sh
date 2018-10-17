#!/bin/sh
set -e

if [ ! -f ./pidfile ]
then
  echo "File pidfile does not exist!"
  exit 1
fi

echo "send SIGTERM signal to contract-validator to terminate ..."
kill -15 $(cat ./pidfile)
echo "contract-validator terminated ..."

