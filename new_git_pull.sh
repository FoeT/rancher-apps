#get the  key from settings/developer/tokens/classic
kubectl create secret docker-registry github-container-registry \
   --namespace weapps \
   --docker-server=ghcr.io \
   --docker-username=FoeT \
   --docker-password=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 \
   --docker-email=forrest.thurgood@gmail.com \
   --dry-run=client -o yaml | kubectl apply -f -
