#!/usr/bin/env bash

set -e

if [[ $1 != "up" ]] && [[ $1 != "down" ]]
then
    echo "Usage arguments either up or down. eg: './deplpy.sh up'"
fi

if [[ $1 == "up" ]]
then
    DEPLOYMENT_NAME=todo-http4s-doobie

    if [ -z $KUBE_TOKEN ]; then
        echo "FATAL: Environment Variable KUBE_TOKEN must be specified."
        exit ${2:-1}
    fi

    if [ -z $NAMESPACE ]; then
        echo "FATAL: Environment Variable NAMESPACE must be specified."
        exit ${2:-1}
    fi

    echo
    echo "Namespace $NAMESPACE"

    status_code=$(curl -sSk -H "Authorization: Bearer $KUBE_TOKEN" \
                       "https://$KUBERNETES_SERVICE_HOST:$KUBERNETES_PORT_443_TCP_PORT/apis/apps/v1beta2/namespaces/$NAMESPACE/deployments/$DEPLOYMENT_NAME" \
                       -X GET -o /dev/null -w "%{http_code}")

    if [ $status_code == 200 ]; then
        echo
        echo "Updating deployment"
        curl --fail -H 'Content-Type: application/strategic-merge-patch+json' -sSk -H "Authorization: Bearer $KUBE_TOKEN" \
             "https://$KUBERNETES_SERVICE_HOST:$KUBERNETES_PORT_443_TCP_PORT/apis/apps/v1beta2/namespaces/$NAMESPACE/deployments/$DEPLOYMENT_NAME" \
             -X PATCH -d @"$DEPLOYMENT_NAME.json"
    else
        echo
        echo "Creating deployment"
        curl --fail -H 'Content-Type: application/json' -sSk -H "Authorization: Bearer $KUBE_TOKEN" \
             "https://$KUBERNETES_SERVICE_HOST:$KUBERNETES_PORT_443_TCP_PORT/apis/apps/v1beta2/namespaces/$NAMESPACE/deployments" \
             -X POST -d @"$DEPLOYMENT_NAME.json"
    fi

    status_code=$(curl -sSk -H "Authorization: Bearer $KUBE_TOKEN" \
                       "https://$KUBERNETES_SERVICE_HOST:$KUBERNETES_PORT_443_TCP_PORT/api/v1/namespaces/$NAMESPACE/services/bulletin-board-service" \
                       -X GET -o /dev/null -w "%{http_code}")

    if [ $status_code == 404 ]; then
        echo
        echo "Creating service"
        curl --fail -H 'Content-Type: application/json' -sSk -H "Authorization: Bearer $KUBE_TOKEN" \
             "https://$KUBERNETES_SERVICE_HOST:$KUBERNETES_PORT_443_TCP_PORT/api/v1/namespaces/$NAMESPACE/services" \
             -X POST -d @bulletin-board-service.json
    fi

    status_code=$(curl -sSk -H "Authorization: Bearer $KUBE_TOKEN" \
                       "https://$KUBERNETES_SERVICE_HOST:$KUBERNETES_PORT_443_TCP_PORT/apis/extensions/v1beta1/namespaces/$NAMESPACE/ingresses/bulletin-board-ingress" \
                       -X GET -o /dev/null -w "%{http_code}")

    if [ $status_code == 404 ]; then
        echo
        echo "Creating ingress"
        curl --fail -H 'Content-Type: application/json' -sSk -H "Authorization: Bearer $KUBE_TOKEN" \
             "https://$KUBERNETES_SERVICE_HOST:$KUBERNETES_PORT_443_TCP_PORT/apis/extensions/v1beta1/namespaces/$NAMESPACE/ingresses" \
             -X POST -d @bulletin-board-ingress.json
    fi
    echo "Bringing todo-http4s-doobie up"
    kubectl apply -f todo-http4s-doobie.yml
fi

if [[ $1 == "down" ]]
then
    echo "Bringing todo-http4s-doobie down"
    kubectl delete -f todo-http4s-doobie.yml
fi
