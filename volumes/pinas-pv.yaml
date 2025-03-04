apiVersion: v1
kind: PersistentVolume
metadata:
  annotations:
    pv.kubernetes.io/bound-by-controller: "yes"
  creationTimestamp: "2025-03-04T06:23:43Z"
  finalizers:
  - kubernetes.io/pv-protection
  name: pinas
  resourceVersion: "38964400"
  uid: dd23ab46-9d98-4056-92bb-269813e5ce56
spec:
  accessModes:
  - ReadWriteOnce
  - ReadWriteMany
  - ReadOnlyMany
  capacity:
    storage: 50Gi
  claimRef:
    apiVersion: v1
    kind: PersistentVolumeClaim
    name: pinas-root
    namespace: weapps
    resourceVersion: "38964396"
    uid: d6d4072c-0188-4447-ab17-55fb5561eabf
  nfs:
    path: /media/zfs-nas-1
    server: 172.16.0.10
  nodeAffinity:
    required:
      nodeSelectorTerms:
      - {}
  persistentVolumeReclaimPolicy: Retain
  volumeMode: Filesystem
status:
  lastPhaseTransitionTime: "2025-03-04T06:24:07Z"
  phase: Bound
