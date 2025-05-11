
---
### 외부 모듈 사용 시 추가 리소스 사용 방법

#### 1. 모듈에서 사용 중인 프로바이더 확인
- `terraform init` 명령어를 실행하여 `.terraform/providers` 디렉터리를 생성합니다.
- 생성된 숨김 디렉터리에서 사용 중인 프로바이더를 확인합니다.

##### 프로바이더 경로 예시
`.terraform/providers/registry.terraform.io/hashicorp/kubernetes/2.36.0/darwin_arm64`

위 경로를 통해 [테라폼 공식문서](https://registry.terraform.io/)에서 해당 프로바이더와 버전을 검색합니다:
  

#### 2. Terraform Registry에서 프로바이더 확인
- 위에서 확인한 프로바이더와 버전을 Terraform Registry에서 검색하여 세부 정보를 확인합니다.

#### 3. 사용할 프로바이더와 설정을 모듈 외부에 provider를 지정합니다.
```
provider "kubernetes" {
  config_path = "~/.kube/config" # kubeconfig 파일 경로
}


module "rancher" {
  source = "squareops/rancher/kubernetes"
  rancher_config = {
    email = ""
    hostname    = ""
    values_yaml = ""
  }
}
```
---