#!/usr/bin/env bash

set -e

if [[ $1 != "up" ]] && [[ $1 != "down" ]]; then
    echo "Usage arguments either up or down. eg: './deplpy.sh up'"
fi

sed -i "s/MASTER_NODE_IP/$KUBERNETES_SERVICE_HOST/g" /home/go/config
mkdir /home/go/.kube
cp /home/go/config /home/go/.kube/config

kubectl config set-cluster minikube --server="$KUBERNETES_SERVICE_HOST:$KUBERNETES_PORT_443_TCP_PORT"
kubectl config use-context minikube

if [[ $1 == "up" ]]; then
    echo "Bringing todo-http4s-doobie up"
    kubectl apply -f todo-http4s-doobie.yml
fi

if [[ $1 == "down" ]]; then
    echo "Bringing todo-http4s-doobie down"
    kubectl delete -f todo-http4s-doobie.yml
fi
