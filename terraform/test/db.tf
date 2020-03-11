resource "aws_rds_cluster" "serverless" {
  cluster_identifier        = "aurora-cluster-${local.environment}"
  engine                    = "aurora"
  engine_version            = "5.6.10a"
  engine_mode               = "serverless"
  availability_zones        = module.vpc.azs
  db_subnet_group_name      = module.vpc.database_subnet_group
  vpc_security_group_ids    = [aws_security_group.dbserver.id]
  database_name             = "notejam"
  master_username           = random_pet.master_username.id
  master_password           = random_password.master_password.result
  deletion_protection       = local.environment == "test" ? false : true
  skip_final_snapshot       = local.environment == "test" ? true : false
  final_snapshot_identifier = local.environment == "test" ? null : "final-${local.environment}"
}

resource "random_pet" "master_username" {
  length = 1
}
resource "random_password" "master_password" {
  length  = 16
  special = false
}