kubectl patch pv pinas -p '{"spec":{"claimRef": null}}'
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pinas-root
  annotations:
    {}
  labels:
    {}
  namespace: weapps
spec:
  selector:
    matchLabels:
  accessModes:
    - ReadWriteOnce
    - ReadOnlyMany
    - ReadWriteMany
  resources:
    requests:
      storage: 10Gi
  storageClassName: ''
  volumeName: pinas
EOF
#kubectl apply -f fleet-repo.yaml
