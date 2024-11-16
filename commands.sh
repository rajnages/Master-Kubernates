########################. Cluster Management########################
# Get cluster info
kubectl cluster-info

# Get nodes status
kubectl get nodes
kubectl describe node <node-name>

# Get cluster events
kubectl get events
kubectl get events --sort-by='.metadata.creationTimestamp'

########################. Pod Operations ########################
# List pods
kubectl get pods
kubectl get pods -o wide
kubectl get pods --all-namespaces
kubectl get pods -n <namespace>

# Pod details
kubectl describe pod <pod-name>
kubectl logs <pod-name>
kubectl logs <pod-name> -c <container-name>  # For multi-container pods
kubectl logs -f <pod-name>  # Follow logs

# Pod management
kubectl delete pod <pod-name>
kubectl exec -it <pod-name> -- /bin/bash
kubectl port-forward <pod-name> 8080:80

#######################Deployment Operations#######################
# List deployments
kubectl get deployments
kubectl get deploy

# Deployment management
kubectl create deployment <name> --image=<image>
kubectl scale deployment <name> --replicas=3
kubectl rollout status deployment/<name>
kubectl rollout history deployment/<name>
kubectl rollout undo deployment/<name>
kubectl rollout undo deployment/<name> --to-revision=2

########################. Service Operations ########################
# List services
kubectl get services
kubectl get svc

# Service management
kubectl expose deployment <name> --port=80 --type=LoadBalancer
kubectl describe service <service-name>

########################. Namespace Operations ########################
# List namespaces
kubectl get namespaces
kubectl get ns

# Create namespace
kubectl create namespace <name>
kubectl delete namespace <name>

########################. ConfigMap Operations and secrets ########################
# ConfigMaps
kubectl get configmaps
kubectl create configmap <name> --from-file=<path>
kubectl create configmap <name> --from-literal=key1=value1

# Secrets
kubectl get secrets
kubectl create secret generic <name> --from-literal=key1=value1

########################. Ingress Operations ########################
# List ingresses
kubectl get ingress
kubectl describe ingress <name>

#########################Troubleshooting Commands#########################
# Debug pods
kubectl describe pod <pod-name>
kubectl logs <pod-name> --previous  # Get crashed container logs
kubectl exec -it <pod-name> -- /bin/bash

# Check cluster health
kubectl get componentstatuses
kubectl top nodes
kubectl top pods

# Network troubleshooting
kubectl run -it --rm debug --image=nicolaka/netshoot -- /bin/bash
kubectl port-forward <pod-name> <local-port>:<pod-port>

############################Advanced Commands############################
# Apply manifests
kubectl apply -f <filename.yaml>
kubectl apply -f <directory>
kubectl apply -f https://raw.githubusercontent.com/...

# Diff changes
kubectl diff -f <filename.yaml>

# JSON output
kubectl get pods -o json
kubectl get pods -o jsonpath='{.items[*].metadata.name}'

# Custom columns
kubectl get pods -o custom-columns=POD:metadata.name,NODE:spec.nodeName