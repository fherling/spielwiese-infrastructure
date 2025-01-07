#!/bin/zsh

# Set the directory path
KUSTOMIZE_DIR="/Users/fherling/Documents/git/spielwiese/infrastructure"

# Check if directory exists
if [[ ! -d "$KUSTOMIZE_DIR" ]]; then
    echo "Error: Directory $KUSTOMIZE_DIR does not exist"
    exit 1
fi

# Check if kustomization.yaml exists
if [[ ! -f "$KUSTOMIZE_DIR/kustomization.yaml" ]]; then
    echo "Error: kustomization.yaml not found in $KUSTOMIZE_DIR"
    exit 1
fi

# SWICHT TO MINIKUBE
kubectl config use-context rancher-desktop

# Create namespace
kubectl create namespace spielwiese

# Execute kubectl kustomize
echo "Running kubectl kustomize for $KUSTOMIZE_DIR"
#kubectl kustomize "$KUSTOMIZE_DIR"

kubectl kustomize "$KUSTOMIZE_DIR" | kubectl apply -f -


kubectl wait pod --all --for=condition=Ready --namespace=spielwiese --timeout=600s


