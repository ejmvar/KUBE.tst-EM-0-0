#!/bin/bash
#
# 
# HPA en Kubernetes: autoescalado de Pods por CPU y RAM | Curso Kubernetes #17
# Pabpereza
#
# https://www.youtube.com/watch?v=QhHzygBoN_8&t=105s
# https://github.com/pabpereza/quotes.git
#

kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

kubectl -n kube-system get pods
kubectl -n kube-system get pods | grep metrics


kubectl apply -f hpa.yml

watch -d kubectl get hpa quotes-hpa

k6 run stress-test.js
kubectl get pods


