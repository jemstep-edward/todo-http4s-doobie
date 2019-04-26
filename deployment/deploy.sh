#!/usr/bin/env bash

set -e

if [[ $1 != "up" ]] && [[ $1 != "down" ]]
then
    echo "Usage arguments either up or down. eg: './deplpy.sh up'"
fi

if [ -z "$2" ]; then
    echo "Plesae supply the second argument as the context to use for deployment."
fi
CONTEXT=$2

if [ -z "$3" ]; then
    echo "Plesae supply the third argument as namespace to use for deployment."
fi
NAMESPACE=$3

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
