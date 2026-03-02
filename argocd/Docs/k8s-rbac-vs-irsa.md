# Kubernetes RBAC vs AWS IRSA

## Kubernetes RBAC — 클러스터 내부 권한

Pod가 Kubernetes 리소스(Pod, Secret 등)에 접근할 때 사용하는 권한 체계.

### 구성 요소

**1. ServiceAccount — 신분증**

일반 사용자가 User Account를 사용하듯, Pod는 ServiceAccount로 자신의 신원을 증명한다.

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: python-sa
  namespace: my-namespace
```

**2. Role — 권한 정의**

어떤 리소스에 어떤 행동을 허용할지 정의한다.

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: pod-reader
  namespace: my-namespace
rules:
- apiGroups: [""]       # core API 그룹
  resources: ["pods"]
  verbs: ["get", "list"]
```

**3. RoleBinding — 신분증과 권한 연결**

ServiceAccount와 Role을 연결한다.

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: read-pods-binding
  namespace: my-namespace
subjects:
- kind: ServiceAccount
  name: python-sa       # 누구에게
roleRef:
  kind: Role
  name: pod-reader      # 어떤 권한을
  apiGroup: rbac.authorization.k8s.io
```

### 흐름

```
Pod → ServiceAccount → RoleBinding → Role → K8s 리소스 접근 허용
```

---

## AWS IRSA — AWS 서비스 접근 권한

Pod가 AWS 서비스(ECR, S3, RDS 등)에 접근할 때 사용하는 권한 체계.
Kubernetes RBAC과 **완전히 별개**의 시스템이다.

### ServiceAccount annotation

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: argocd-image-updater-controller
  annotations:
    eks.amazonaws.com/role-arn: arn:aws:iam::097600221977:role/<ROLE_NAME>
```

annotation은 RBAC과 무관하다. EKS의 **Pod Identity Webhook**이 이 값을 읽어 AWS 인증을 처리한다.

### 동작 흐름

```
ServiceAccount annotation 감지 (EKS Webhook)
        ↓
AWS STS에 AssumeRoleWithWebIdentity 요청
        ↓
임시 AWS 자격증명 발급
        ↓
Pod 환경변수에 자동 주입
(AWS_ROLE_ARN, AWS_WEB_IDENTITY_TOKEN_FILE)
        ↓
ECR / S3 등 AWS 서비스 접근 성공
```

### IAM Role 신뢰 정책 (Trust Policy)

"이 ServiceAccount가 이 Role을 사용할 수 있다"고 AWS에 등록한다.

```json
{
  "Effect": "Allow",
  "Principal": {
    "Federated": "arn:aws:iam::097600221977:oidc-provider/<EKS_OIDC_PROVIDER>"
  },
  "Action": "sts:AssumeRoleWithWebIdentity",
  "Condition": {
    "StringEquals": {
      "<EKS_OIDC_PROVIDER>:sub": "system:serviceaccount:argocd:argocd-image-updater-controller"
    }
  }
}
```

---

## 두 시스템 비교

| | Kubernetes RBAC | AWS IRSA |
|---|---|---|
| 제어 대상 | K8s 클러스터 내부 리소스 | AWS 서비스 (ECR, S3 등) |
| 권한 정의 위치 | Role / ClusterRole | IAM Role Policy |
| 연결 방법 | RoleBinding | ServiceAccount annotation |
| 판단 주체 | Kubernetes API Server | AWS STS |

### 핵심

- **RBAC**: "이 Pod는 K8s에서 무엇을 할 수 있는가"
- **IRSA**: "이 Pod는 AWS에서 무엇을 할 수 있는가"

두 권한이 모두 필요한 경우 **함께** 설정해야 한다.

---

## 트러블슈팅 — argocd-image-updater ECR 인증 실패

### 증상

```
Could not get tags from registry: Get "https://<account>.dkr.ecr.<region>.amazonaws.com/v2/<image>/tags/list": no basic auth credentials
```

IRSA가 설정되어 있음에도 ECR 접근 시 basic auth 실패가 발생하는 경우.

### 원인

`argocd-image-updater-config` ConfigMap에 `registries.conf`가 없으면, controller가 ECR을 일반 registry로 인식하고 basic auth를 시도한다. IRSA로 AWS 자격증명이 주입되어 있어도 registry 설정이 없으면 사용되지 않는다.

### 1단계 — IRSA 동작 확인

```bash
kubectl exec -n argocd deployment/argocd-image-updater-controller -- env | grep AWS
```

정상이면 아래 두 변수가 존재해야 한다:

```
AWS_ROLE_ARN=arn:aws:iam::<account>:role/<role-name>
AWS_WEB_IDENTITY_TOKEN_FILE=/var/run/secrets/eks.amazonaws.com/serviceaccount/token
```

변수가 없으면 → EKS OIDC provider 및 IAM Trust Policy 확인 필요.

### 2단계 — registries.conf 확인

```bash
kubectl get configmap argocd-image-updater-config -n argocd -o yaml
```

`data` 섹션이 비어 있거나 `registries.conf` 키가 없으면 아래로 진행.

`registries.conf`가 없으면 controller는 이미지 이름만 보고 어떤 레지스트리인지, 어떻게 인증할지 알 수 없다. 결국 기본값인 Docker Hub 방식(basic auth)으로 시도하다 실패한다.

```
097600221977.dkr.ecr.ap-northeast-2.amazonaws.com/python-app
        ↑ ECR인지 모름 → basic auth 시도 → 실패
```

`registries.conf`의 역할은 `prefix`로 이미지 이름을 매칭해 "이건 ECR이다"라고 인식시키고, ECR에 맞는 인증 방식(AWS SDK → IRSA 자격증명)을 사용하도록 하는 **라우팅 + 인증 설정**이다.

### 3단계 — registries.conf 추가

`registries.conf`는 YAML 형식이다. install YAML 파일의 ConfigMap에 `data` 섹션을 추가한다.

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: argocd-image-updater-config
  namespace: argocd
data:
  registries.conf: |
    registries:
    - name: AWS ECR
      api_url: https://<account>.dkr.ecr.<region>.amazonaws.com
      prefix: <account>.dkr.ecr.<region>.amazonaws.com
      credentials: ecr:<region>
      credsexpire: 10h
```

`credentials: ecr:<region>`은 argocd-image-updater 빌트인 ECR 인증 방식으로, IRSA로 주입된 AWS 자격증명을 사용해 ECR 토큰을 자동 발급한다. `/scripts/ecr-login.sh` 같은 외부 스크립트가 필요 없다.

> **주의:** TOML 형식(`[[registries]]`)은 파싱 에러가 발생한다. 반드시 YAML 형식을 사용한다.

적용:

```bash
kubectl apply -f argocd-image-updater.install.yaml
kubectl rollout restart deployment argocd-image-updater-controller -n argocd
```

### 판단 흐름

```
IRSA 환경변수 있음?
  └─ No  → EKS OIDC provider / Trust Policy 확인
  └─ Yes → registries.conf 설정 있음?
              └─ No  → ConfigMap에 ECR registry 추가
              └─ Yes → IAM Role 권한 정책(ecr:GetAuthorizationToken 등) 확인
```
