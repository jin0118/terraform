# Argo CD Image Updater - Rollback & Re-deploy Sequence Diagram

```mermaid
sequenceDiagram
    participant Dev as 개발팀
    participant Reg as Container Registry
    participant IU as Image Updater
    participant K8s as Kubernetes API
    participant ArgoCD as Argo CD

    Note over ArgoCD: auto-sync 활성화 상태

    IU->>Reg: 최신 태그 조회
    Reg-->>IU: 태그 반환
    IU->>K8s: Application source 업데이트
    K8s-->>ArgoCD: 변경 감지
    ArgoCD->>ArgoCD: auto-sync → 배포

    Note over ArgoCD: 장애 발생

    Dev->>ArgoCD: rollback 요청
    ArgoCD->>ArgoCD: 이전 버전으로 복구
    ArgoCD->>K8s: auto-sync 비활성화

    Note over IU: rollback 상태 인식 못함

    loop Reconciliation 계속
        IU->>Reg: 최신 태그 조회
        Reg-->>IU: 태그 반환
        IU->>K8s: Application source 업데이트 (계속)
        Note over K8s,ArgoCD: auto-sync 꺼져 있으므로<br/>실제 배포는 발생 안 함
    end

    Dev->>Dev: 원인 파악 & 코드 수정
    Dev->>Reg: 새 이미지 빌드 & push

    IU->>Reg: 최신 태그 조회
    Reg-->>IU: 새 태그 반환
    IU->>K8s: Application source 업데이트 (새 태그)

    Dev->>ArgoCD: 상태 확인 후 수동 sync
    ArgoCD->>ArgoCD: 새 이미지로 배포
    Note over ArgoCD: 필요 시 auto-sync 재활성화
```

## 핵심 포인트

| 상태 | Image Updater | Argo CD |
|------|--------------|---------|
| 정상 운영 | registry 조회 → source 업데이트 | auto-sync → 자동 배포 |
| rollback 직후 | source 업데이트 계속 (rollback 인식 못함) | auto-sync 비활성화 → 실제 배포 안 함 |
| 수정 후 재배포 | 새 태그 감지 → source 업데이트 | 운영자 확인 후 수동 sync |

## 환경별 권장 전략

| 환경 | auto-sync | 이유 |
|------|-----------|------|
| dev / staging | 켜둠 | 빠른 피드백 루프 |
| production | 꺼둠 | rollback 안전성 + 배포 승인 프로세스 |
