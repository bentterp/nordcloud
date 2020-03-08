data "aws_ami" "c7" {
#  executable_users = ["self"]
  most_recent      = true
#  name_regex       = "^myami-\\d{3}"
  owners           = ["679593333241"]

  filter {
    name   = "description"
    values = ["CentOS Linux 7 x86_64 HVM EBS ENA *"]
  }

}




module "server" {
  source                      = "terraform-aws-modules/ec2-instance/aws"
  ami                         = data.aws_ami.c7.id
  associate_public_ip_address = true
  instance_type               = "t3.micro"
  name                        = "${local.environment}jam"
  user_data_base64            = data.template_cloudinit_config.config.rendered
  key_name                    = "bentkey"
  subnet_ids                  = module.vpc.public_subnets
  vpc_security_group_ids      = [ aws_security_group.adminssh.id, aws_security_group.flaskserver.id , aws_security_group.outboundanyany.id ]
  root_block_device           = [{ delete_on_termination : "true" }]
}

data "template_file" "cloudinit" {
  template = "${file("${path.module}/cloudinit.tpl")}"

  vars = {
    db_host = aws_rds_cluster.serverless.endpoint
    db_name = aws_rds_cluster.serverless.database_name
    db_user = aws_rds_cluster.serverless.master_username
    db_pass = aws_rds_cluster.serverless.master_password
  }

}
data "template_cloudinit_config" "config" {
  gzip          = true
  base64_encode = true
  part {
    content_type = "text/x-shellscript"
    content      = "${data.template_file.cloudinit.rendered}"
  }
}

output "ssh_login" {
  value = "ssh centos@${local.serverip}"
}

output "website" {
  value = "curl http://${local.serverip}:5000"
}
