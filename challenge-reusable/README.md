# terraform
도전: 모듈을 만들어서 각기 다른 태그를 가지는 VPC, Subnet, EC2를 생성한다

# 폴더 구조
```bash
challenge-resuable/ 
├── _modules/
    ├── main.tf
    ├── variables.tf
├── prod-ec2
    ├── terraform.tf
    ├── variables.tf
├── test-ec2
    ├── terraform.tf
    ├── variables.tf
``` 

- terraform.tf<br>
    modules{}에 ../modules/variables.tf를 기준으로 속성 값을 입력한다.<br>
- prod-ec2/variables.tf<br>
    tags의 array 구조로 가독성이 좋지 않으면 variables.tf를 활용한다.



# 실행
prod-ec2 / test-ec2 각각에서 테라폼 코드를 실행한다.

