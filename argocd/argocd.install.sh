aws eks update-kubeconfig --region ap-northeast-2 --name imageupdater-poc --profile lsj6445z
kubectl create namespace argocd
kubectl apply -n argocd --server-side --force-conflicts -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}' 
kubectl get svc argocd-server -n argocd -o=jsonpath='{.status.loadBalancer.ingress[0].ip}'
brew install argocd
kubectl apply -f argocd/argocd-image-updater.install.yaml -n argocd
kubectl apply -f argocd/applicataion.yaml -n argocd
argocd admin initial-password -n argocd
