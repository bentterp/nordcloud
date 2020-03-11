locals {
  environment = "test"
  serverip    = concat(module.server.public_ip, [""]).0
}
