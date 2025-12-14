# vmware resources variables

datacenter          = "Datacenter"
datastore           = "toto"
folder              = "Templates"
cluster             = "nothing_cluster"
resource_pool       = "resource"
esxi_host           = "192.168.150.166"
template_name       = "debian-12-template"
host_domain         = "host.vsphere.example.com"
tech_domain         = "tech.vsphere.example.com"
os_type             = "debian" # or "debian"

env = {
  name = "vspheredev"
  type = "dev"
  hosting = "vmware"
}

regions = {
  dummy: ""
}

networks = {
  frontend = {
    name = "VM Network",
    ip_range = "192.168.150.0/24"
    region = "dummy"
  }
  backend  = {
    name = "toto",
    ip_range = "10.0.0.0/24"
    region = "dummy"
  }
  cluster  = {
    name = "toto",
    ip_range = "172.16.0.0/24"
    region = "dummy"
  }
}

# 

servers = {
  "main" = {
    image           = "bookworm"
    size            = "tiny"
    public_ip       = "main_ip"
    sql_server_id   = 1
    hostname        = "main"
    region          = "dummy"
    network         = "frontend"
    reverse         = "smtp"
    private_ip_num  = 10
    roles           = ["bastion", "api_server", "cert_manager", "sql_master", "smtp", "mx", "imap_front", "imap_store", "ox", "webfront", "mail_filter", "kube"]
    api_sql         = "main"
    imap_sql        = "main"
    smtp_sql        = "main"
    ox_sql          = "main"
    ox_name         = "oxserver"
    ox_store        = "file"
    ox_params       = ["imap", "prov"]
    kube_flavor     = "k3s"
    local_volumes   = []
    volumes = [
      { name = "maildir",      mount = "/var/mail"     },
      { name = "logs",         mount = "/var/log/mail" },
      { name = "certificates", mount = "/opt/certs"    },
      { name = "mysql1",       mount = "/var/mysql"    },
    ]
  }
  "backup" = {
    image           = "bookworm"
    size            = "normal"
    public_ip       = "backup_ip"
    sql_server_id   = 2
    hostname        = "backup"
    region          = "dummy"
    network         = "frontend"
    private_ip_num  = 11

    roles           = ["bastion", "backup_sql", "backup_mail", "cert_user", "solr", "kube_worker"]
    control_plane   = "main"
    backup_sql_src  = [ "main:5" ]
    backup_mail_src = [ "main" ]
    ox_name    = "oxserver"
    ox_store   = "file"
    ox_params  = ["imap"]

    local_volumes   = []
    volumes = [
      { name = "maildir2",      mount = "/backup/mail/main"  },
      { name = "logs2",         mount = "/var/log/mail"        },
      { name = "certificates2", mount = "/opt/certs"           },
      { name = "mysql2",        mount = "/backup/mysql/main" }
    ]
  },
  "monitor" = {
    image           = "bookworm"
    size            = "normal"
    public_ip       = "monitor_ip"
    hostname        = "monitor"
    region          = "dummy"
    network         = "frontend"
    private_ip_num  = 12

    roles = ["monitor", "bastion", "cert_user", "kubectl"],
    kubes = ["main"]
    local_volumes   = []
    volumes = [
      { name = "certificates3", mount = "/opt/certs" }
    ]
  },
}


kube_apps = {
  "ox-8" = {
     "services"     = ["webfront:8888"],
     "targets"      = ["sql_master:3306", "backup_sql:3307-3326", "mail_filter:783"],
     "app"          = "ox8",
     "kube"         = "main",
  },
}
 

volumes = {
  "maildir"      = { region = "dummy", size = 1, type = "high-speed" },
  "mysql1"       = { region = "dummy", size = 1,  type = "high-speed" },
  "logs"         = { region = "dummy", size = 1,  type = "classic" },
  "certificates" = { region = "dummy", size = 1,   type = "classic" },

  "maildir2"      = { region = "dummy", size = 1, type = "classic" },
  "mysql2"        = { region = "dummy", size = 1,  type = "classic" },
  "logs2"         = { region = "dummy", size = 1,  type = "classic" },
  "certificates2" = { region = "dummy", size = 1,   type = "classic" },
  "certificates3" = { region = "dummy", size = 5, type = "classic" }
  "certificates4" = { region = "dummy", size = 5, type = "classic" }
}
