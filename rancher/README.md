### TODO
- [ ] CRDs 설치 됐는지 확인하라는 에러 해결
```
│ Error: unable to build kubernetes objects from release manifest: resource mapping not found for name: "rancher" namespace: "" from "": no matches for kind "Issuer" in version "cert-manager.io/v1" 
ensure CRDs are installed first
```
- [ ] cert-manager 학습 
    - 참고 자료:
        - [ 쿠버네티스 cert-manager로 let's encrypt 인증서 발급](https://malwareanalysis.tistory.com/126)
        - [cert-manager란?](https://www.infograb.net/1a927690-fd7a-489f-beb1-b0dab6c1bbff)
        - [cert-manager 공식문서](https://cert-manager.io/docs/)
- [ ] Terraform으로 kind-cluster에 설치





