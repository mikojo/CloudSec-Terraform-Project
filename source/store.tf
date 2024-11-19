resource "aws_ssm_parameter" "database_password" {
  name = "${local.ssm_path_database}/password"
  type = "SecureString"
  value = random_password.password.result
}

resource "aws_ssm_parameter" "database_username" {
  name = "${local.ssm_path_database}/username"
  type = "String"
  value = var.database_username
}