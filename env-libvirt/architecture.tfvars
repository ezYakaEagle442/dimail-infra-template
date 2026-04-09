env = {
  name = "libvirt"
  type = "dev"
  hosting = "libvirt"  
}

host_domain = "host.libvirt.example.com"
tech_domain = "tech.libvirt.example.com"

network_range = "192.168.100.0/24"
networks = { "libvirt": {
  ip_range = "192.168.100.0/24"
  is_public = true
  region = "le_sud" 
}}
regions = {"le_sud": "le_sud"}
volumes = {}

servers = {
  "main" = {
    "size" = "c2r8"
    "private_ip_num" = 10
    "roles" = ["api_server", "cert_manager", "sql_master", "smtp", "mx", "imap_front", "imap_store", "webfront", "kube", "mail_filter", "ox", "cert_manager", "bastion", "garage"]
    "kube_flavor" = "k3s"
    "api_sql" = "main"
    "smtp_sql" = "main"
    "imap_sql" = "main"
    "ox_sql" = "main"
    "ox_name" = "oxserver"
    "ox_store" = "s3"
    "ox_params" = ["imap", "prov"]
    "sql_server_id" = 1
    "image" = ""
    "local_volumes" = []
    "network" = "libvirt"
    "volumes" = []
  },
  "monitor" = {
    "size" = "c1r1"
    "private_ip_num" = 20
    "roles" = ["cert_user", "monitor", "kubectl"]
    "kubes" = ["main"]
    "image" = ""
    "local_volumes" = []
    "network" = "libvirt"
    "volumes" = []
  },
  "backup" = {
    "size" = "c2r8",
    "private_ip_num" = 30
    "roles" = ["cert_user", "backup_sql", "backup_mail", "kube_worker", "solr"]
    "control_plane" = "main"
    "backup_sql_src" = ["main:2"]
    "backup_mail_src" = ["main"]
    "image" = ""
    "local_volumes" = []
    "network" = "libvirt"
    "volumes" = []
  }
}


kube_apps = {
  "ox8imap" = {
     "services"     = ["webfront:8888"],
     "targets"      = ["sql_master:3306", "backup_sql:3307-3326", "mail_filter:11223"],
     "app"          = "ox8",
     "kube"         = "main",
  },
  "ox8oidc" = {
     "services"     = ["webfront:8888"],
     "targets"      = ["sql_master:3306", "backup_sql:3307-3326", "mail_filter:11223"],
     "app"          = "ox8-oidc",
     "kube"         = "main",
  },
}
