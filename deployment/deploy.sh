#!/usr/bin/env bash

set -e

if [[ $1 != "up" ]] && [[ $1 != "down" ]]
then
    echo "Usage arguments either up or down. eg: './deplpy.sh up'"
fi

if [ -z "$2" ]; then
    echo "Plesae supply the second argument as the host to use for deployment."
fi
HOST=$2

if [ -z "$3" ]; then
    echo "Plesae supply the third argument as namespace to use for deployment."
fi
NAMESPACE=$3

if [ -z "$4" ]; then
    echo "Please supply the fourth argument as the name of the context to use for deployment."
fi
CONTEXT=$4

echo "Registering cluster on host: $HOST"
kubectl config set-cluster "$CONTEXT" --server="https://$HOST" --insecure-skip-tls-verify

echo "Switching to the context: $CONTEXT"
kubectl config use-context "$CONTEXT"

echo "Using the namespace: $NAMESPACE"
kubectl config set-context --current --namespace="$NAMESPACE"

if [[ $1 == "up" ]]
then
    echo "Bringing todo-http4s-doobie up"
    kubectl apply -f deployment.yml
fi

if [[ $1 == "down" ]]
then
    echo "Bringing todo-http4s-doobie down"
    kubectl delete -f deployment.yml
fi
