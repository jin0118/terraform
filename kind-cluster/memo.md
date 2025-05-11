


kubectl 자동완성
- https://my-grope-log.tistory.com/37
```
brew install bash-completion@2
export BASH_COMPLETION_COMPAT_DIR="/opt/homebrew/etc/bash_completion.d"
kubectl completion bash >/opt/homebrew/etc/bash_completion.d/kubectl
echo 'export BASH_COMPLETION_COMPAT_DIR="/opt/homebrew/etc/bash_completion.d"'
echo 'alias k=kubectl' >>~/.bash_profile
echo 'complete -F __start_kubectl k' >>~/.bash_profile
```


