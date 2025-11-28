########################## OVH Project #################################
env = {
  name = "proxmoxdev"
  type = "dev"
  hosting = "proxmox"
}

regions = {
   "main"   = "proxmox"
   "backup" = "proxmox"
}

tech_domain = "tech.proxmox.example.com"
host_domain = "host.proxmox.example.com"
ttl = 600

### os_k8s_ip_range = "171.33.65.126/32"

### private_network_name = "backend-network"
dns_nameservers = [
  "213.186.33.99", # OVH default DNS
  "80.67.169.12",  # FDN
  "8.8.8.8",       # Google DNS
]

servers = {
  "main" = {
    image           = "bookworm"
    size            = "big"
    public_ip       = "main_ip"
    sql_server_id   = 1
    hostname        = "main"
    region          = "main"
    network         = "main"
    reverse         = "smtp"
    private_ip_num  = 10

    roles           = ["bastion", "api_server", "cert_manager", "sql_master", "smtp", "mx", "imap_front", "imap_store", "ox", "webfront", "mail_filter"]
    api_sql         = "main"
    imap_sql        = "main"
    smtp_sql        = "main"
    ox_sql          = "main"
    ox_name         = "oxserver"
    ox_store        = "file"
    ox_params       = ["imap", "prov"]

    local_volumes   = []
    volumes = [
      { name = "maildir",      mount = "/var/mail"     },
      { name = "logs",         mount = "/var/log/mail" },
      { name = "certificates", mount = "/opt/certs"    },
      { name = "mysql1",       mount = "/var/mysql"    }
    ]
  },
  "backup" = {
    image           = "bookworm"
    size            = "normal"
    public_ip       = "backup_ip"
    sql_server_id   = 2
    hostname        = "backup"
    region          = "backup"
    network         = "backup"
    private_ip_num  = 11

    roles           = ["bastion", "backup_sql", "backup_mail", "cert_user", "solr"]
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
    region          = "main"
    network         = "main"
    private_ip_num  = 12

    roles = ["monitor", "bastion", "cert_user"],

    local_volumes   = []
    volumes = [
      { name = "certificates3", mount = "/opt/certs" }
    ]
  },
}

volumes = {
  "maildir"      = { region = "main", size = 1, type = "high-speed" },
  "mysql1"       = { region = "main", size = 1,  type = "high-speed" },
  "logs"         = { region = "main", size = 1,  type = "classic" },
  "certificates" = { region = "main", size = 1,   type = "classic" },

  "maildir2"      = { region = "backup", size = 1, type = "classic" },
  "mysql2"        = { region = "backup", size = 1,  type = "classic" },
  "logs2"         = { region = "backup", size = 1,  type = "classic" },
  "certificates2" = { region = "backup", size = 1,   type = "classic" },

  "certificates3" = { region = "main", size = 5, type = "classic" }

  "certificates4" = { region = "main", size = 5, type = "classic" }
}

# Ces lignes sont là pour ressembler à Outscale, mais ne sont pas utilisées chez OVH.
network_range = "10.100.0.0/16"
networks = {
  "main" = {
    "ip_range"  = "10.10.0.0/24"
    "region"    = "main"
    "is_public" = true
  }
  "backup" = { 
    "ip_range"  = "10.10.1.0/24" 
    "region"    = "backup"
    "is_public" = true
  }
}
 
### global_private_networks = {
###   "backend-network" = {
###     vrack_vlan_id = 42
###     cidr          = "172.21.0.0/16"
###     new_bits      = 4
###     regions       = [ "main", "backup", "SBG5", "RBX-A" ]
###     dns_servers = [
###       "213.186.33.99", # OVH default DNS
###       "80.67.169.12",  # FDN
###       "8.8.8.8",       # Google DNS
###     ]
###   }
### }
