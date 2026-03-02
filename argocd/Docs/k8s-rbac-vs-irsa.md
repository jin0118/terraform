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
