# Makefile for Kubernetes Starter project

APP_NAME=hello-app
NAMESPACE=hello
IMAGE_TAG=1.0

dev-up:
	docker build -t $(APP_NAME):$(IMAGE_TAG) ./app
	minikube image load $(APP_NAME):$(IMAGE_TAG)
	kubectl apply -f k8s/manifests

test-load:
	kubectl run load-generator \
		--rm -i --tty \
		--image=busybox \
		--restart=Never \
		-- /bin/sh -c "while true; do wget -q -O- http://$(APP_NAME).hello.svc.cluster.local/; done"

status:
	kubectl get pods -o wide
	kubectl get svc
	kubectl get hpa

down:
	kubectl delete -f k8s/manifests || true
