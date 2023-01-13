variable "example_docker_compose" {
    type = string
    default =  <<EOF
version: "3.1"
services:
  myapp:
    image: amanbangash99/spring-petclinic:latest
    restart: always
    ports:
      - 8080
EOF
}