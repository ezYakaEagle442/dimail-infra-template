########################## Outscale Project #################################
env = {
  name = "outscaledev"
  type = "dev"
  hosting = "outscale"
}

regions = {
  "main"   = "eu-west-2a"
  "backup" = "eu-west-2a"  # pas de multi-région simple avec Outscale
}

# https://registry.terraform.io/providers/outscale/outscale/latest/docs/data-sources/account

# Outscale account ID
outscale_account_id = "your-account-id"

# domaine où seront les enregistrements des serveurs liés à la plateforme
tech_domain = "host.outscale-example.com"

# domain où seront les enregistrements dédié à la messagerie (MX, imap etc.)
host_domain = "tech.outscale-example.com"

ttl = 300

# DNS nameservers par défaut
dns_nameservers = [
  "185.31.196.1",   # Outscale default DNS
  "8.8.8.8",        # Google DNS
]

# https://registry.terraform.io/providers/outscale/outscale/latest/docs/resources/vm
# https://registry.terraform.io/providers/outscale/outscale/latest/docs/resources/volume
# https://registry.terraform.io/providers/outscale/outscale/latest/docs/data-sources/images

# https://blog.stephane-robert.info/docs/cloud/outscale/fondations/calcul-instances-tina-sizing/
# 
# small   = "tinav7.c1r1p2"
# medium1 = "tinav7.c1r2p2"
# medium  = "tinav7.c2r4p2"
# large   = "tinav7.c4r4p2"
# xlarge  = "tinav7.c8r64p2"

servers = {
  "bastion" = {
    image         = "Ubuntu-24.04-2026-04-14" # https://docs.outscale.com/fr/userguide/R%C3%A9f%C3%A9rence-des-OMI-officielles.html
    sql_server_id = ""
    network       = "main"
    roles         = ["bastion"]
    size          = "tinav7.c1r1p2"
    local_volumes = []
    volumes = []
  }
  "main" = {
    image           = "rocky-9"
    size            = "t2.medium"
    public_ip       = "main_ip"
    sql_server_id   = 1
    hostname        = "main"
    region          = "main"
    network         = "main"
    private_ip_num  = 10
    roles           = ["api_server", "cert_manager", "bastion", "sql_master", "ox", "webfront", "mail_filter", "imap_store", "smtp", "mx", "imap_front"]
    imap_sql        = "main"
    smtp_sql        = "main"
    api_sql         = "main"
    ox_sql          = "main"
    ox_name         = "single-server"
    ox_store        = "file"
    ox_params       = ["imap", "prov"]

    local_volumes = []
    volumes = [
      { name = "maildir",      mount = "/var/mail" },
      { name = "logs",         mount = "/var/log/mail" },
      { name = "certificates", mount = "/opt/certs" },
      { name = "mysql1",       mount = "/var/mysql" },
    ]
  }
}