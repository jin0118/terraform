# Argo CD Image Updater - 설치 및 동작 방식

## install.yaml로 설치되는 리소스

```
CustomResourceDefinition   ← ImageUpdater 리소스 타입 등록
Deployment                 ← 실제 컨트롤러 Pod
ServiceAccount             ↑
Role / ClusterRole         │ 컨트롤러 동작에 필요한 RBAC
RoleBinding                │
ClusterRoleBinding         ↓
ConfigMap                  ← 컨트롤러 설정
Secret                     ← 인증 정보
Service                    ← 메트릭 노출용
NetworkPolicy              ← 메트릭 트래픽 허용
```

---

## CRD vs 컨트롤러

| | 역할 |
|---|---|
| CRD | ImageUpdater 리소스 타입을 K8s에 등록 (설계도, 실행 안 함) |
| 컨트롤러 (Deployment) | Application annotation 또는 ImageUpdater CR을 감시하고 실제 업데이트 수행 |
| CR | CRD로 정의된 타입의 실제 인스턴스 (사용자가 생성) |

---

## 두 가지 사용 방식

### 1. Annotation 방식 (simple)

CRD 불필요. Argo CD Application 리소스에 직접 annotation을 추가합니다.

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: my-app
  annotations:
    argocd-image-updater.argoproj.io/image-list: myimage=docker.io/myorg/myapp
    argocd-image-updater.argoproj.io/myimage.update-strategy: newest-build
    argocd-image-updater.argoproj.io/myimage.allow-tags: ^prd-
```

### 2. CR 방식

별도 ImageUpdater CR을 생성합니다.

```yaml
apiVersion: argoproj.io/v1alpha1
kind: ImageUpdater
metadata:
  name: my-updater
spec:
  applicationRefs:
    - name: my-app
  images:
    - image: docker.io/myorg/myapp
      updateStrategy: newest-build
      allowTags: "^prd-"
```

---

## 방식 비교

| | Annotation 방식 | CR 방식 |
|---|---|---|
| CRD 필요 여부 | 불필요 | 필요 |
| 설정 위치 | Application 리소스에 직접 | 별도 ImageUpdater CR |
| 복잡도 | 단순 | 상대적으로 복잡 |
| 관심사 분리 | Application과 업데이트 정책 혼재 | 분리됨 |
| 다수 App 관리 | App마다 annotation 반복 | 하나의 CR로 여러 App 관리 가능 |

두 방식 모두 **컨트롤러(Deployment)** 가 감시하고 동작을 수행합니다.
