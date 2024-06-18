# run these commands in order to set up kiali and cosmo wundergraph
#!/bin/bash

helm install --namespace istio-system --set auth.strategy="anonymous" --repo https://kiali.org/helm-charts kiali-server kiali-server

helm upgrade --install cosmo oci://ghcr.io/wundergraph/cosmo/helm-charts/cosmo --version 0.0.1 --values ./values.yaml --namespace="cosmo" --create-namespace --cleanup-on-fail 

helm upgrade --install router oci://ghcr.io/wundergraph/cosmo/helm-charts/router --version 0.0.1 --values ./routerConfig.yaml --namespace="cosmo" --cleanup-on-fail 