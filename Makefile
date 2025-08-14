.PHONY: install start build requirements apply

requirements:
	minikube addons enable ingress
install:
	python3 -m venv venv
	. venv/bin/activate && cd ./app/ && pip install --upgrade pip && pip install -r requirements.txt
start:
	minikube start --cpus=2 --memory=4096
build:
	docker build app -t hello-api:develop
	# Load the image into the minikube registry
	minikube image load hello-api:develop
redeploy:
	minikube kubectl -- -n develop rollout restart deployment/hello-api
	minikube kubectl -- -n develop rollout status deployment/hello-api
apply:
	minikube kubectl -- apply -f k8s/namespace.yaml
	minikube kubectl -- apply -f k8s/deployment.yaml
	minikube kubectl -- apply -f k8s/service.yaml
	minikube kubectl -- apply -f k8s/secret.yaml
	minikube kubectl -- apply -f k8s/ingress.yaml
tls:
	openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
		-keyout .secrets/tls/hello.local.key -out .secrets/tls/hello.local.crt \
		-subj "/CN=hello.local" \
		-addext "subjectAltName=DNS:hello.local"
	minikube kubectl -- -n develop delete secret hello-api-tls
	minikube kubectl -- -n develop create secret tls hello-api-tls --key .secrets/tls/hello.local.key --cert .secrets/tls/hello.local.crt
	minikube kubectl -- -n develop get secret hello-api-tls -o yaml | kubectl neat > .secrets/tls-secret.yaml
