#!/bin/bash

# Loop through all nodes with the label 'worker'
for node in $(kubectl get nodes -l worker -o jsonpath='{.items[*].metadata.name}'); do
  echo "Processing node: $node"
  

  kubectl cordon $node
  echo "Cordon node: $node"

  kubectl drain $node --ignore-daemonsets --delete-local-data
  echo "Drain node: $node"

  # Optionally, delete the node after all pods are deleted
  echo "Deleting node: $node"
  kubectl delete node $node

  # Loop through all pods on the current node
  #for pod in $(kubectl get pods --all-namespaces --field-selector spec.nodeName=$node -o jsonpath='{.items[*].metadata.name}'); do
  #  namespace=$(kubectl get pod $pod --all-namespaces -o jsonpath='{.metadata.namespace}')
  #  echo "Deleting pod: $pod in namespace: $namespace on node: $node"
  #  kubectl delete pod $pod -n $namespace
  #done
done

