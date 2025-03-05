#get the  key from settings/developer/tokens/classic
kubectl create secret docker-registry github-container-registry \
   --namespace weapps \
   --docker-server=ghcr.io \
   --docker-username=FoeT \
   --docker-password=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 \
   --docker-email=forrest.thurgood@gmail.com \
   --dry-run=client -o yaml | kubectl apply -f -
