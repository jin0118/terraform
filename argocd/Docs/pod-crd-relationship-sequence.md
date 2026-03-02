# argocd-image-updater Pod ↔ my-image-updater CRD 관계

```mermaid
sequenceDiagram
    participant Pod as argocd-image-updater<br/>(Pod/Controller)
    participant K8s as Kubernetes API
    participant CRD as my-image-updater<br/>(ImageUpdater CRD)
    participant ECR as Amazon ECR
    participant Argo as ArgoCD Application<br/>(python-*)

    Pod->>K8s: ImageUpdater CRD watch 등록
    K8s-->>Pod: watch 승인

    loop Reconciliation Loop
        K8s->>Pod: CRD 변경 이벤트 (생성/수정)
        Pod->>K8s: my-image-updater spec 조회
        K8s-->>CRD: spec 반환
        CRD-->>Pod: applicationRefs, images 설정 전달

        Pod->>K8s: "python-*" 패턴으로 ArgoCD Application 목록 조회
        K8s-->>Pod: python-app Application 반환

        Pod->>ECR: python-app 이미지 최신 태그 조회
        ECR-->>Pod: 태그 목록 반환

        alt 새 태그 존재
            Pod->>K8s: ArgoCD Application image 태그 업데이트
            K8s-->>Argo: Application 변경 감지
            Argo->>Argo: 새 이미지로 Sync 수행
        else 변경 없음
            Pod->>Pod: skip
        end
    end
```

## 역할 요약

| 리소스 | 타입 | 역할 |
|--------|------|------|
| `argocd-image-updater` | Pod (Controller) | CRD를 감시하고 실제 업데이트 로직 실행 |
| `my-image-updater` | ImageUpdater CRD | 업데이트 대상 앱/이미지 정책 선언 |
| `python-*` | ArgoCD Application | 실제 이미지 태그가 갱신되는 대상 |

- Pod는 **엔진**, CRD는 **설정**
- Pod가 없으면 CRD는 동작하지 않음
- CRD가 없으면 Pod는 업데이트 대상을 알 수 없음
