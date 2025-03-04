kubectl patch pv pinas -p '{"spec":{"claimRef": null}}'
kubectl apply -f fleet-repo.yaml
