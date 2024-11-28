# Rick and Morty API Demo Showcase

This project provides a complete showcase of a GraphQL application aimed at comparing classical REST with GraphQL and demonstrating GraphQL's capabilities. It comprises several different pods that can be spun up in a Kubernetes cluster.

## Requirements

1. A running Kubernetes cluster
2. Helm
3. Node installed

## Components to Run

1. **[Istio](https://istio.io/latest/docs/setup/install/helm/)** + **[Kiali](https://kiali.io/)** + **[Jaeger](https://www.jaegertracing.io/)** to collect distributed traces and data for benchmarking.
2. **MongoDB** to store data for the application.
3. **Ariadne**: A Python microservice built on the Ariadne GraphQL framework to showcase a simple authentication mechanism.
4. **Ariadnews**: A Python microservice built on the Ariadne GraphQL framework.
5. **Rick-and-Morty-API**: A Node.js microservice built on the open-source [Rick and Morty API](https://github.com/afuh/rick-and-morty-api).
6. **Spring-graphql** A Java Springboot microservice using  [Spring GraphQL library](https://spring.io/projects/spring-graphql).
7. **WunderGraph**: Files to spin up [Cosmo WunderGraph](https://wundergraph.com/), an open-source alternative for creating GraphQL federation that combines our three GraphQL APIs, allowing access from a single endpoint.

## Setup Guide
**Please change default username/passwords before deploying anywhere, they are just an example**

### Preliminary steps: microservices, db, ingress controller
- Run ```make``` to build the images for all microservices and to run them (TODO: create Makefile to build the images)
- Spin up nginx moving to the nginx-ingress folder and running ```helm install my-release .``` (necessary if you want to access the cluster from the outside)
### Wundergraph Cosmo
- Move to the wundergraph folder and install the cosmo platform using 
```
 helm upgrade --install cosmo oci://ghcr.io/wundergraph/cosmo/helm-charts/cosmo \
    --version 0.12.3 \
    --values ./values-cosmo-platform-new.yaml
```
- Use ```kubectl apply -f cosmoPlatformIngress.yaml``` to create ingresses towards the cosmo platform services
- Add the following entries to your hosts file:
```
127.0.0.1 controlplane.example.com
127.0.0.1 studio.wundergraph.local
127.0.0.1 router.wundergraph.local
127.0.0.1 keycloak.wundergraph.local
127.0.0.1 otelcollector.wundergraph.local
127.0.0.1 graphqlmetrics.wundergraph.local
127.0.0.1 cdn.wundergraph.local
```
- Check connectivity to the controlplane by trying to reach out http://controlplane.example.com in your browser, it should give you a json with an error 404. If it gives you 502 nginx error, try ```kubectl delete -f cosmoPlatformIngress.yaml``` and then ```kubectl apply -f cosmoPlatformIngress.yaml``` and ```kubectl rollout restart deployment <name of the nginx controller deployment>```
- Open a command window and export ```COSMO_API_URL=http://controlplane.example.com``` and ```COSMO_API_KEY=cosmo_669b576aaadc10ee1ae81d9193425705```
- Install wgc using node ```npm install -g wgc@latest```
- Run ```npx wgc federated-graph list``` to test connectivity to your controlplane, if it fails and tells you to auth **DO NOT** auth (it is trying to log in the cloud instead of your local cluster) and check for typos in the env variables and errors in the logs of nginx controller pod/cosmo controplane pod
- Create and publish subgraphs by running the following commands:
```
npx wgc subgraph create ariadne --label app=A --routing-url http://ariadne-service.default.svc.cluster.local:8083
npx wgc subgraph publish ariadne ./ariadneSchema.graphql
npx wgc subgraph create ariadnews --label app=A --routing-url  http://ariadnews-svc.default.svc.cluster.local:8083
npx wgc subgraph publish ariadnews ./ariadnewsSchema.graphql --subscription-protocol ws
npx wgc subgraph create ramapi --label app=A --routing-url http://ramapi-service.default.svc.cluster.local:8082/graphql
npx wgc subgraph publish ramapi ./ramapiSchema.graphql
npx wgc subgraph create spring --label app=A --routing-url http://spring-svc.default.svc.cluster.local:8084/graphql
npx wgc subgraph publish spring ./spring.graphql --subscription-protocol ws --websocket-subprotocol graphql-transport-ws
```
- Run 
```
npx wgc federated-graph create test -r http://router.wundergraph.local --label-matcher app=A
```
 to create the graph, please **SAVE** the api token that is generated in this step! 
- Open the ```values-router-new.yaml``` file and edit the **graphApiToken** string under the **configuration** section, use the api token generated in the previous step
- Deploy the cosmo router with
 ```
helm upgrade --install router oci://ghcr.io/wundergraph/cosmo/helm-charts/router \
    --version 0.9.0 \
    --values ./values-router-new.yaml
```
- Try to connect from your browser to http://router.wundergraph.local and check that wundergraph playground opens correctly
### Additional observability tools: Istio, Kiali, Grafana, Jaeger (not covered in detail)
- Install istio using helm, in short:
```
kubectl create namespace istio-system
helm install istio-base istio/base -n istio-system --set defaultRevision=default
helm install istiod istio/istiod -n istio-system --wait
```
- Install Kiali with ```kubectl apply -f kiali.yaml``` or by running:
```
helm install --namespace istio-system --set auth.strategy="anonymous" --repo https://kiali.org/helm-charts kiali-server kiali-server
```
- Install jaeger using ```kubectl apply -f jaeger.yaml```
- Run ```kubectl apply -f ingress_jaeger.yaml``` and ```kubectl apply -f ingress_kiali.yaml```
- Add the following entries to hosts file:
```
127.0.0.1 kiali.foo.org
127.0.0.1 jaeger.example.com
```
- Access to http://kiali.foo.org and http://jaeger.example.com with your browser to ensure everything is working fine