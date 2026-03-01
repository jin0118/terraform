# Argo CD Image Updater - Update Strategy

## 지원 전략

| 전략 | 설명 |
|------|------|
| `semver` | semantic versioning 제약 기준으로 최신 버전 업데이트 |
| `newest-build` | registry에 가장 최근 push된 이미지로 업데이트 |
| `digest` | 특정 태그의 SHA digest 기준으로 업데이트 |
| `name/alphabetical` | 태그를 알파벳 정렬 후 가장 높은 순서로 업데이트 |

---

## 케이스: ECR에서 prd-* 태그 기준 업데이트

### 태그 형식이 일관되지 않은 경우

```
prd-java-11-20260301   # java 버전 포함
prd-20260301           # 날짜만 포함
```

### 전략별 적합성

| 전략 | 사용 가능 여부 | 이유 |
|------|--------------|------|
| `semver` | 불가 | prd-java-11-20260301은 semver 형식이 아님 |
| `newest-build` | 가능 | push 시간 기준이므로 태그 형식 무관 |
| `digest` | 불가 | 특정 태그 고정 추적용 |
| `name/alphabetical` | 불가 | prd-2... vs prd-j... 알파벳 비교 시 날짜 순서 보장 안 됨 |

### newest-build 설정

```yaml
apiVersion: argoproj.io/v1alpha1
kind: ImageUpdater
spec:
  images:
    - image: 123456789.dkr.ecr.ap-northeast-2.amazonaws.com/my-app
      updateStrategy: newest-build
      allowTags: "^prd-"        # prd- 로 시작하는 태그만 대상
```

### 동작 예시

```
ECR 태그 목록:
  prd-java-11-20260301  (push: 2026-03-01 09:00)
  prd-java-11-20260228  (push: 2026-02-28 09:00)
  dev-20260301          (push: 2026-03-01 10:00)  ← allowTags로 제외

→ prd-java-11-20260301 선택 (prd-* 중 가장 최근 push)
```

---

## 주의사항

`newest-build`는 ECR에 push된 시간 기준이므로, 오래된 이미지를 재push하면 그게 선택될 수 있음.

의도치 않은 업데이트 방지를 위해 **prd- 태그는 항상 새로 빌드한 이미지에만 붙이는 CI/CD 규칙** 필요.
