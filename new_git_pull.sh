#get the  key from settings/developer/tokens/classic
kubectl create secret docker-registry github-container-registry \
   --namespace weapps \
   --docker-server=ghcr.io \
   --docker-username=FoeT \
   --docker-password=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 \
   --docker-email=forrest.thurgood@gmail.com \
   --dry-run=client -o yaml | kubectl apply -f -
