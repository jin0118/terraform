# terraform
도전: 모듈을 만들어서 각기 다른 태그를 가지는 VPC, Subnet, EC2를 생성한다

# 폴더 구조
challenge-resuagble/
├── _modules/
    ├── main.tf
    ├── variables.tf
├── prod-ec2
    ├── terraform.tf : modules{}에 ../modules/variables.tf를 기준으로 속성 값을 입력한다
    ├── variables.tf : tags와 같이 가독성 떨어지는 속성 값을 넣어준다
├── test-ec2
    ├── terraform.tf
    ├── variables.tf


# 싫랭
prod-ec2 / test-ec2 각각에서 테라폼 코드를 실행한다.

