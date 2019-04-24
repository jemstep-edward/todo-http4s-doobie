#!/usr/bin/env bash

set -e

if [[ $1 != "up" ]] && [[ $1 != "down" ]]
then
    echo "Usage arguments either up or down. eg: './deplpy.sh up'"
fi

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
