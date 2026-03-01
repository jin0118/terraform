# Argo CD Image Updater - Reconciliation Sequence Diagram

```mermaid
sequenceDiagram
    participant C as Controller
    participant K8s as Kubernetes API
    participant Reg as Container Registry
    participant ArgoCD as Argo CD

    loop Reconciliation Loop
        C->>K8s: ImageUpdater CR 목록 조회
        K8s-->>C: ImageUpdater CR 반환

        loop 각 ImageUpdater CR
            C->>K8s: 해당 namespace의 Argo CD Application 목록 조회
            K8s-->>C: Application 목록 반환

            C->>C: applicationRefs의 name pattern / label selector로 매칭

            loop 각 매칭된 Application
                C->>C: CR의 image configurations 처리

                loop 각 image configuration
                    C->>K8s: Application에 해당 이미지 배포 여부 확인
                    Note over C,K8s: registry 포함 strict 매칭<br/>(docker.io vs quay.io 구분)

                    alt 이미지가 eligible
                        C->>Reg: 최신 이미지 태그 조회
                        Note over C,Reg: update strategy, allowed/ignore tags,<br/>platform 조건 적용
                        Reg-->>C: 태그 목록 반환

                        C->>C: update strategy에 따라 최신 버전 결정

                        alt 더 새로운 버전 존재
                            C->>K8s: Application source 업데이트<br/>(manifest 직접 수정 X)
                            K8s-->>ArgoCD: Application 변경 감지
                            ArgoCD->>ArgoCD: 새 이미지 태그로 sync 수행
                        else 업데이트 불필요
                            C->>C: skip
                        end
                    else 이미지 불일치 (registry 다름 등)
                        C->>C: skip
                    end
                end
            end
        end
    end
```

## 주요 흐름 요약

| 단계 | 설명 |
|------|------|
| CR 감시 | Controller가 ImageUpdater CR을 지속적으로 감시 |
| Application 매칭 | name pattern / label selector 기준으로 대상 Application 필터링 |
| 이미지 적합성 검사 | registry까지 포함한 strict 매칭으로 eligible 여부 판단 |
| Registry 조회 | update strategy + 제약 조건 적용해 최신 태그 탐색 |
| Application 업데이트 | manifest 직접 수정 없이 Application source만 변경 → Argo CD에게 위임 |
