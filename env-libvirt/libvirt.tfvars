env = {
  name = "libvirt"
  type = "dev"
  hosting = "libvirt"  
}

host_domain = "example.com"
tech_domain = "tech.example.com"

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
    "roles" = ["api_server", "cert_manager", "sql_master", "smtp", "mx", "imap_front", "imap_store", "webfront", "kube", "mail_filter", "ox", "cert_manager"],
    "image" = "",
    "local_volumes" = [],
    "network" = "libvirt",
    "volumes" = [],
  },
  "monitor" = {
    "size" = "c1r1"
    "private_ip_num" = 20
    "roles" = ["cert_user", "monitor", "kubectl"],
    "image" = "",
    "local_volumes" = [],
    "network" = "libvirt",
    "volumes" = [],
  },
  "backup" = {
    "size" = "c2r8",
    "private_ip_num" = 30
    "roles" = ["cert_user", "backup_sql", "backup_mail", "kube_worker", "solr"],
    "image" = "",
    "local_volumes" = [],
    "network" = "libvirt",
    "volumes" = [],
  }
}
