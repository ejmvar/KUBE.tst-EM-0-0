#!/bin/bash
#
# https://www.youtube.com/watch?v=isIwnFrDmfE
#

kubectl proxy --port=8001
curl localhost:8001
curl localhost:8001/api/v1/namespaces/kube-system/pods?limit=1
curl localhost:8001/api/v1/namespaces/kube-system/pods
