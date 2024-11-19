variable "region" {
  default = "us-east-1"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "vpc_name" {
  default = "capstone_vpc"
}

variable "subnetnames" {
  default = ["capstone-private-sn1", "capstone-public-sn1", "capstone-public-sn2", "capstone-private-sn2"]
  type    = list(any)
}

variable "capstone-public-subnet1" {
  default = "10.0.1.0/24"
}

variable "capstone-private-subnet1" {
  default = "10.0.2.0/24"
}

variable "capstone-public-subnet2" {
  default = "10.0.3.0/24"
}

variable "capstone-private-subnet2" {
  default = "10.0.4.0/24"
}

variable "az" {
  default = ["us-east-1a", "us-east-1b"]
  type    = list(any)
}

variable "internet_gateway_name" {
  default = "capstone_igw"
}


variable "web_ports" {
  default = [3306, 2049, 80, 443]
  type    = list(any)
}

variable "public_access" {
  type    = bool
  default = false
}

variable "rds_identifier" {
  type    = string
  default = "capstone"
}

variable "rds_db_name" {
  type    = string
  default = "capstone_db"
}

variable "database_username" {
  type    = string
  default = "admin"
}

variable "instance_class" {
  default = "db.t3.micro"
}

variable "iam_database_authentication_enabled" {
  default = false
}

/*variable "ecs_task_role" { 
  default = "arn:aws:iam::431877974142:role/ECS_Task_Definition"
}


variable "ecs_task_execution_role" {
  default = "arn:aws:iam::431877974142:role/ecsTaskExecutionRole"
}*/

variable "target-group-name" {
  type    = string
  default = "capstone-alb-group"
}

variable "elb-name" {
  type    = string
  default = "capstone-alb"
}


variable "elb-type" {
  default = "application"
  type    = string
}

variable "certificate_arn" {
  type    = string
  default = "arn:aws:acm:us-east-2:431877974142:certificate/554b507e-65b1-4194-bc68-05293aa55694"
}

variable "capstone-access-pt" {
  type    = string
  default = "capstone-efs-access-point"
}

variable "ecs-service-name" {
  default = "ecs-capstone-service"
  type    = string
}

variable "listener-forward-type" {
  default = "forward"
}

variable "hosted_zone_id" {
  default = "Z0024725E6TXJWBO3XTZ"
  type    = string
}

variable "nat-gw-ip" {
  default = "10.0.0.5"
}