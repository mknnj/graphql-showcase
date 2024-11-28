DOCKER_BUILDKIT=1
SERVICES = ariadne ariadnews rick-and-morty-api spring-graphql
.PHONY: all
all: build-and-Deploy

.PHONY: build-and-deploy
build-and-deploy:
    @for service in $(SERVICES); do \
        echo "Building and deploying $$service..."; \
        cd $$service && \
        docker build -t $$service . && \
        kubectl apply -f deployment.yaml && \
        cd ..; \
    done

# Deploy mongo 
.PHONY: mongo
mongo:
    @echo "Applying Mongo deployment and volume..."
    cd mongo && \
    kubectl apply -f deployment.yaml && \
    kubectl apply -f volume.yaml

# Build mongo-initializer and apply job
.PHONY: rick-and-morty-data
rick-and-morty-data:
    @echo "Building mongo-initializer and running init job to create Rick and Morty collections..."
    cd rick-and-morty-data && \
    docker build -t mongo-initializer . && \
    kubectl apply -f init-job.yaml

# Combine all steps together
.PHONY: deploy
deploy: all mongo rick-and-morty-data
    @echo "All services deployed successfully!"