# Makefile for Kubernetes Starter project

APP_NAME=hello-app
NAMESPACE=hello
VERSION ?= 1.0
IMAGE=$(APP_NAME):$(VERSION)

.PHONY: dev-up test-load status down alias-kubectl

dev-up:
	docker build -t $(IMAGE) ./app
	minikube image load $(IMAGE)
	minikube kubectl -- apply -f k8s/manifests -n $(NAMESPACE)

# Load test using 'hey'
# Usage overrides:
#   make test-load C=100 N=20000 Z=2m Q=20
# Defaults: C=50 (concurrency), N=10000 (requests), Z=2m (duration), Q=20 (reqs/worker/sec)
test-load:
	hey -c $${C:-50} -n $${N:-10000} -z $${Z:-2m} -q $${Q:-20} http://hello.local/

status:
	minikube kubectl -- get pods -n $(NAMESPACE) -o wide
	minikube kubectl -- get svc -n $(NAMESPACE)
	minikube kubectl -- get hpa -n $(NAMESPACE)

down:
	minikube kubectl -- delete -f k8s/manifests -n $(NAMESPACE) || true

# Print out kubectl alias for convenience (not persisted)
alias-kubectl:
	@echo 'Run this in your shell to create the alias:'
	@echo '  alias kubectl="minikube kubectl --"'
