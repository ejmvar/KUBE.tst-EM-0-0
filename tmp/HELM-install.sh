#!/bin/bash

cd kubernetes/helm

helm install [NAME] [CHART] [flags]
helm install [NAME is the release=] [CHART is the chart name = folder] [flags : -f my-values.yaml]
... --values example-app/example-app-01.values.yaml


heml install example-app example-app 

--values
--set
--set-string

? --set-file
? --set-value

# ---
Feedback:

release