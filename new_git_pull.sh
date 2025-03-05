#get the  key from settings/developer/tokens/classic
kubectl create secret docker-registry github-container-registry \
   --namespace weapps \
   --docker-server=ghcr.io \
   --docker-username=FoeT \
   --docker-password=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 \
   --docker-email=forrest.thurgood@gmail.com \
   --dry-run=client -o yaml | kubectl apply -f -
