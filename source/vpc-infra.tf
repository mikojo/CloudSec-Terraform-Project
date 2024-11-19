resource "aws_vpc" "capstone-vpc" {
  cidr_block = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = var.vpc_name
  }
}

resource "aws_subnet" "capstone-public-subnet1" {
  vpc_id            = aws_vpc.capstone-vpc.id
  cidr_block        = var.capstone-public-subnet1
  availability_zone = var.az[0]
  tags = {
    Name = var.subnetnames[1]
  }
}

resource "aws_subnet" "capstone-public-subnet2" {
  vpc_id            = aws_vpc.capstone-vpc.id
  cidr_block        = var.capstone-public-subnet2
  availability_zone = var.az[1]
  tags = {
    Name = var.subnetnames[2]
  }
}

resource "aws_subnet" "capstone-private-subnet1" {
  vpc_id            = aws_vpc.capstone-vpc.id
  cidr_block        = var.capstone-private-subnet1
  availability_zone = var.az[0]
  tags = {
    Name = var.subnetnames[0]
  }
}


resource "aws_subnet" "capstone-private-subnet2" {
  vpc_id            = aws_vpc.capstone-vpc.id
  cidr_block        = var.capstone-private-subnet2
  availability_zone = var.az[1]
  tags = {
    Name = var.subnetnames[3]
  }
}


resource "aws_route_table" "capstone-private-route-table" {
  vpc_id = aws_vpc.capstone-vpc.id
  tags = {
    Name = "capstone-private-route-table"
  }
}


resource "aws_route_table" "capstone-public-route-table" {
  vpc_id = aws_vpc.capstone-vpc.id
  tags = {
    Name = "capstone-public-route-table"
  }
}

resource "aws_route_table_association" "capstone-public-subnet1-association" {
  subnet_id      = aws_subnet.capstone-public-subnet1.id
  route_table_id = aws_route_table.capstone-public-route-table.id
}

resource "aws_route_table_association" "capstone-public-subnet2-association" {
  subnet_id      = aws_subnet.capstone-public-subnet2.id
  route_table_id = aws_route_table.capstone-public-route-table.id
}

resource "aws_route_table_association" "capstone-private-subnet1-association" {
  subnet_id      = aws_subnet.capstone-private-subnet1.id
  route_table_id = aws_route_table.capstone-private-route-table.id
}

resource "aws_route_table_association" "capstone-private-subnet2-association" {
  subnet_id      = aws_subnet.capstone-private-subnet2.id
  route_table_id = aws_route_table.capstone-private-route-table.id
}

resource "aws_internet_gateway" "capstone-internet-gw" {
  vpc_id = aws_vpc.capstone-vpc.id

  tags = {
    Name = var.internet_gateway_name
  }
}

resource "aws_route" "public-route-table-route-for-igw" {
  route_table_id         = aws_route_table.capstone-public-route-table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.capstone-internet-gw.id
}


/*resource "aws_eip" "eip-for-nat-gw" {
  associate_with_private_ip = var.nat-gw-ip
  tags = {
    Name = "Cloudsec-eip"
  }
}

resource "aws_nat_gateway" "cloudsec-nat-gw" {
  allocation_id = aws_eip.eip-for-nat-gw.id
  subnet_id     = aws_subnet.public_sn1.id

  tags = {
    Name = "Cloudsec-nat-gw"
  }

}

resource "aws_route" "private-route-table-route-for-nat-gw" {
  route_table_id         = aws_route_table.private-route-table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_nat_gateway.cloudsec-nat-gw.id
}*/

resource "aws_security_group" "rds_security_group" {
  name        = "rds_security_group"
  description = "security group for rds"
  vpc_id      = aws_vpc.capstone-vpc.id

  ingress {
    from_port       = var.web_ports[0]
    protocol        = "TCP"
    to_port         = var.web_ports[0]
    security_groups = [aws_security_group.ecs_security_group.id]
    description     = "Allow traffic from the ecs"
  }
}

resource "aws_security_group" "ecs_security_group" {
  name        = "ecs_security_group"
  description = "security group for ecs"
  vpc_id      = aws_vpc.capstone-vpc.id

  ingress {
    from_port       = var.web_ports[2]
    protocol        = "TCP"
    to_port         = var.web_ports[2]
    cidr_blocks     = ["0.0.0.0/0"]
    description     = "Allow traffic from the internet"
  }

  ingress {
    from_port       = var.web_ports[2]
    protocol        = "TCP"
    to_port         = var.web_ports[2]
    security_groups = [aws_security_group.elb_security_group.id]
    description     = "Allow traffic from elb"
  }


   ingress {
    from_port       = var.web_ports[3]
    protocol        = "TCP"
    to_port         = var.web_ports[3]
    security_groups = [aws_security_group.elb_security_group.id]
    description     = "Allow traffic from elb"
  }

  ingress {
    from_port       = var.web_ports[3]
    protocol        = "TCP"
    to_port         = var.web_ports[3]
    cidr_blocks     = ["0.0.0.0/0"]
    description     = "Allow traffic from the internet"
  }
 
  egress {
    from_port   = var.web_ports[0]
    protocol    = "TCP"
    to_port     = var.web_ports[0]
    cidr_blocks = ["0.0.0.0/0"]
  }

    egress {
    from_port   = var.web_ports[1]
    protocol    = "TCP"
    to_port     = var.web_ports[1]
    cidr_blocks = ["0.0.0.0/0"]
  }

    egress {
    from_port   = var.web_ports[2]
    protocol    = "TCP"
    to_port     = var.web_ports[2]
    cidr_blocks = ["0.0.0.0/0"]
  }

    egress {
    from_port   = var.web_ports[3]
    protocol    = "TCP"
    to_port     = var.web_ports[3]
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "efs_security_group" {
  name        = "efs_sg"
  description = "route traffic to ecs security group"
  vpc_id      = aws_vpc.capstone-vpc.id

  ingress {
    from_port   = var.web_ports[1]
    protocol    = "TCP"
    to_port     = var.web_ports[1]
    security_groups = [aws_security_group.ecs_security_group.id]
    description = "Allow traffic from ecs"
  }
}

resource "aws_security_group" "elb_security_group" {
  name        = "elb_sg"
  description = "route traffic to ecs"
  vpc_id      = aws_vpc.capstone-vpc.id

  ingress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow web traffic to load balancer"
  }

  egress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "random_password" "password" {
  length           = 12
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

/*resource "aws_ssm_parameter" "database_password" {
  name = "${local.ssm_path_database}"
  type = "SecureString"
  value = random_password.password.result
}

resource "aws_ssm_parameter" "database_username" {
  name = "${local.ssm_path_database}/username"
  type = "String"
  value = var.database_username
}*/

resource "aws_db_subnet_group" "capstone-subnet-group" {
  name       = "capstone-subnet-group"
  subnet_ids = [aws_subnet.capstone-private-subnet1.id, aws_subnet.capstone-private-subnet2.id]
                 
  tags = {
    Name = "capstone-subnet-group"
  }
}

resource "aws_db_instance" "capstone-rds" {
  allocated_storage                   = 20
  identifier                          = var.rds_identifier
  db_name                             = var.rds_db_name
  engine                              = "mysql"
  engine_version                      = "8.0.35"
  instance_class                      = var.instance_class
  username                            = aws_ssm_parameter.database_username.value 
  password                            = aws_ssm_parameter.database_password.value
  port                                = "3306"
  storage_type                        = "gp3"
  db_subnet_group_name                = "capstone-subnet-group"
  vpc_security_group_ids              = [aws_security_group.rds_security_group.id]
  skip_final_snapshot                 = true
  iam_database_authentication_enabled = var.iam_database_authentication_enabled
  deletion_protection                 = false
  publicly_accessible                 = var.public_access
}


resource "aws_efs_file_system" "capstone-efs" {
  encrypted      =  true
    tags = {
    Name = "capstone-fs"
  }
}

resource "aws_efs_mount_target" "capstone-efs-mt1" {
  file_system_id = aws_efs_file_system.capstone-efs.id
  subnet_id      = aws_subnet.capstone-private-subnet1.id
  security_groups = [ aws_security_group.efs_security_group.id ]
}

resource "aws_efs_mount_target" "capstone-efs-mt2" {
  file_system_id = aws_efs_file_system.capstone-efs.id
  subnet_id      = aws_subnet.capstone-private-subnet2.id
  security_groups = [ aws_security_group.efs_security_group.id ]
  }



resource "aws_efs_access_point" "capstone-access-pt" {
  file_system_id = aws_efs_file_system.capstone-efs.id

  tags = {
    name        = var.capstone-access-pt
    description = "Allow access to EFS"
  }
}

resource "aws_ecs_cluster" "capstone-cluster" {
  name = "capstone-cluster"
}

resource "aws_ecs_cluster_capacity_providers" "capstone-cluster-capacity" {
  cluster_name = aws_ecs_cluster.capstone-cluster.name

  capacity_providers = ["FARGATE"]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = "FARGATE"
  }
}

resource "aws_cloudwatch_log_group" "capstone-ecs-logs" {
  name = "/ecs/capstone-logs"

}

resource "aws_iam_role" "ecs-task-execution-role" {
  name = "ecs-task-execution-role1"
 
  assume_role_policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Action": "sts:AssumeRole",
     "Principal": {
       "Service": "ecs-tasks.amazonaws.com"
     },
     "Effect": "Allow",
     "Sid": ""
   }
 ]
}
EOF
}

resource "aws_iam_role" "ecs-task-role" {
  name = "ecs-task-role1"
 
  assume_role_policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Action": "sts:AssumeRole",
     "Principal": {
       "Service": "ecs-tasks.amazonaws.com"
     },
     "Effect": "Allow",
     "Sid": ""
   }
 ]
}
EOF
}
 
resource "aws_iam_role_policy_attachment" "ecs-task-role-policy-attachment" {
  role       = aws_iam_role.ecs-task-role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonElasticFileSystemClientFullAccess"
}

resource "aws_iam_role_policy_attachment" "ecs-task-execution-role-policy-attachment" {
  role       = aws_iam_role.ecs-task-execution-role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"

}

resource "aws_ecs_task_definition" "capstone-task-definition" {
  family                   = "capstone-family"
  task_role_arn            = aws_iam_role.ecs-task-role.arn
  execution_role_arn       = aws_iam_role.ecs-task-execution-role.arn
  network_mode             = "awsvpc"
  cpu                      = "1024"
  memory                   = "3072"
  requires_compatibilities = ["FARGATE"]
  
  container_definitions    = jsonencode([
    {
      name      = "wordpress",
      image     = "wordpress:php8.3-apache",
      cpu       = 1024,  # 1 vCPU = 1024 units
      memory    = 3072,  # 3 GB = 3072 MB
      essential = true,
      portMappings = [
        {
          containerPort = 80,
          hostPort      = 80
        }
      ],
      logConfiguration = {
        logDriver = "awslogs",
        options = {
          awslogs-region        = "us-east-1",
          awslogs-group         = "/ecs/capstone-logs",
          awslogs-stream-prefix = "ecs",
          awslogs-create-group  = "true"                # Ensure the log group is created automatically if it doesn't exist
        }
      },
      environment = [
        {
          name  = "WORDPRESS_DB_HOST",
          value = aws_db_instance.capstone-rds.endpoint
        },
        {
          name  = "WORDPRESS_DB_USER",
          value = aws_ssm_parameter.database_username.value
        },
        {
          name  = "WORDPRESS_DB_PASSWORD",
          value = aws_ssm_parameter.database_password.value
        },
        {
          name  = "WORDPRESS_DB_NAME",
          value = var.rds_db_name
        }
      ]
    }
  ])

  volume {
    name = "capstone-efs-volume"

    efs_volume_configuration {
      file_system_id          = aws_efs_file_system.capstone-efs.id
      root_directory          = "/"
      transit_encryption      = "ENABLED"
      transit_encryption_port = 2049
      authorization_config {
        access_point_id = aws_efs_access_point.capstone-access-pt.id
        iam             = "ENABLED"
      }
    }
  }
}


resource "aws_lb_target_group" "capstone-target-group" {
  name        = var.target-group-name
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_vpc.capstone-vpc.id

  health_check {
    path     = "/wp-admin/install.php"
    protocol = "HTTP"
  }
}


resource "aws_lb" "capstone-elb" {
  name               = var.elb-name
  internal           = false
  load_balancer_type = var.elb-type
  security_groups    = [aws_security_group.elb_security_group.id]
  subnets            = [aws_subnet.capstone-public-subnet1.id, aws_subnet.capstone-public-subnet2.id]

  enable_deletion_protection = false

  tags = {
    Environment = "dev"
  }
}

resource "aws_lb_listener" "capstone-listener" {
  load_balancer_arn = aws_lb.capstone-elb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = var.listener-forward-type
    target_group_arn = aws_lb_target_group.capstone-target-group.arn
  }
}

# resource "aws_lb_listener" "capstone-listener-SSL" {
#   load_balancer_arn = aws_lb.capstone-elb.arn
#   port              = "443"
#   protocol          = "HTTPS"
#   certificate_arn   = var.certificate_arn

#   default_action {
#     type             = var.listener-forward-type
#     target_group_arn = aws_lb_target_group.capstone-target-group.arn
#   }
# }

resource "aws_ecs_service" "capstone-service" {
  name            = var.ecs-service-name
  cluster         = aws_ecs_cluster.capstone-cluster.id
  task_definition = aws_ecs_task_definition.capstone-task-definition.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  health_check_grace_period_seconds = 300

  network_configuration {
    subnets         = [aws_subnet.capstone-public-subnet1.id, aws_subnet.capstone-public-subnet2.id]
    security_groups = [aws_security_group.ecs_security_group.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.capstone-target-group.arn
    container_name   = "wordpress"
    container_port   = 80
  }
}

# resource "aws_route53_record" "cloudsec_dns" {
#   zone_id = var.hosted_zone_id
#   allow_overwrite = true
#   name    = "seyramgabriel.com"
#   type    = "A"

#   alias {
#     name                   = aws_lb.cloudsec_elb.dns_name
#     zone_id                = aws_lb.cloudsec_elb.zone_id
#     evaluate_target_health = true
#   }
# }
