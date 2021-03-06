kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
  name: azure-file
provisioner: kubernetes.io/azure-file
parameters:
  storageAccount: MANAGED_SA
reclaimPolicy: Delete
allowVolumeExpansion: true
mountOptions:
  - dir_mode=0777
  - file_mode=0777
  - mfsymlinks
  - cache=strict
  - actimeo=30