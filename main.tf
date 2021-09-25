#main
module "networking" {
  source   = "./modules/networking"
  vpc_cidr = "10.123.0.0/16"
  #Hardcoded
  #    public_cidrs = ["10.123.2.0/24","10.123.4.0/24"]
  #    private_cidrs = ["10.123.1.0/24","10.123.3.0/24","10.123.5.0/24"]
  security_groups  = local.security_groups
  private_sn_count = 3
  public_sn_count  = 2
  max_subnets      = 10
  public_cidrs     = [for i in range(2, 255, 2) : cidrsubnet("10.123.0.0/16", 8, i)] #it will be limited by the public_sn_count var
  private_cidrs    = [for i in range(1, 255, 2) : cidrsubnet("10.123.0.0/16", 8, i)]
  access_ip        = var.access_ip
  db_subnet_group  = true
}
module "database" {
    source = "./modules/database"
    db_storage = 10
    db_engine_version = "5.7.22" 
    db_instance_class = "db.t2.micro"
    dbname = var.dbname
    dbuser = var.dbuser
    dbpassword = var.dbpassword
    db_subnet_group_name = module.networking.dbsub_id
    vpc_security_group_id = module.networking.rds_sg
    db_identifier = "bazan-db"
    skip_db_snap = true
}

module "lb" {
  source                 = "./modules/loadblancer"
  public_sg              = module.networking.public_sg
  public_subnets         = module.networking.pub_subnets
  lbname                 = "K3s-Lb"
  port_tg_port           = 8000
  tg_protocol            = "http"
  vpc_id                 = module.networking.vpc_id
  lb_healthy_threshold   = 2
  lb_unhealthy_threshold = 2
  lib_timeout            = 3
  lb_interval            = 30
  listener_port          = 8000
  listener_protocol      = "HTTP"
} 

module "compute" {
    source = "./modules/compute"
    instance_count = 2
    instance_type = "t3.micro"
    public_sg = module.networking.public_sg
    public_subnets = module.networking.pub_subnets
    vol_size = 10
    key_name = "bazan_key"
    public_key_path = "./id_rsa.pub"
    user_data_path = "${path.root}/userdata.tpl"
    db_endpoint = module.database.db_endpoint
    dbuser = var.dbuser
    dbpassword = var.dbpassword
    dbname = var.dbname
    lb_target_group_arn = module.lb.lb_target_group_arn
    tg_port = 8000
}