########################## OVH Project #################################
env = {
  name = "ovhdev"
  type = "dev"
  hosting = "ovh"
}

regions = {
  "main"   = "GRA7"
  "backup" = "SBG7"
}

# ovh_public_cloud_project_name = "infra-mail-dgf-staging"
ovh_public_cloud_project_id = "1c5fd1e61d9940bc912a4d571277bd18"


# domaine où seront les enregistrements des serveurs liés à la plateforme
tech_domain = "host.example.com"

# domain où seront les enregistrements dédié à la messagerie (MX, imap etc.)
host_domain = "tech.example.com"

ttl = 300 # à adapter…  pour du dev c'est bien. En production, prévoir beaucoup plus (24h ?)

ovh_openstack_tenant_id   = "same-as-ovh-public-cloud-project-id"
ovh_openstack_tenant_name = "tenant-name-from-horizon"

# ces enregistrements DNS seront repris pour configurer les instances
dns_nameservers = [
  "213.186.33.99", # OVH default DNS
  "80.67.169.12",  # FDN
  "8.8.8.8",       # Google DNS
]

servers = {
  "bastion" = {
    image         = "bookworm"
    sql_server_id = ""
    network       = "main"
    roles         = ["bastion"]
    size          = "small"
    local_volumes = []
    volumes = []
  }
  "main" = {
    image           = "bookworm"
    size            = "normal"
    public_ip       = "main_ip"
    sql_server_id   = 1           # id de serveur mysql pour replication, doit être différent pour toutes les instances mysql
    hostname        = "main"
    region          = "main"      # doit être une clé de régions
    network         = "main"
    private_ip_num  = 10          # 172.16.40.10 si le réseau est 172.16.40.0/24
    roles           = ["api_server", "cert_manager", "bastion", "sql_master", "ox", "webfront", "mail_filter", "imap_store", "smtp", "mx", "imap_front"]
    imap_sql        = "main"
    smtp_sql        = "main"
    api_sql         = "main"
    ox_sql          = "main on backup"
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
  },
  "kube" = {
    image           = "bookworm"
    size            = "normal"
    public_ip       = "kube_ip"
    sql_server_id   = 1           # id de serveur mysql pour replication, doit être différent pour toutes les instances mysql
    hostname        = "main"
    region          = "main"      # doit être une clé de régions
    network         = "main_priv"
    private_ip_num  = 18          # 172.16.40.10 si le réseau est 172.16.40.0/24
    roles           = ["kube"]
    imap_sql        = "main"
    smtp_sql        = "main"
    api_sql         = "main"
    ox_sql          = "main on backup"
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
  },
  "kube_worker" = {
    image           = "bookworm"
    size            = "normal"
    public_ip       = "kube_worker_ip"
    sql_server_id   = 1           # id de serveur mysql pour replication, doit être différent pour toutes les instances mysql
    hostname        = "main"
    region          = "main"      # doit être une clé de régions
    network         = "main_priv"
    private_ip_num  = 20         
    roles           = ["kube_worker"]
    control_plane   = "kube"
    local_volumes = []
    volumes = []
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

    roles      = ["bastion", "backup_mail", "backup_sql", "cert_user"]
    backup_mail_src = [ "main"]
    backup_sql_src  = [ "main:4"]
    local_volumes = []
    volumes = [
      #{ name = "maildir2",          mount = "/var/mail" },
      { name = "logs2",              mount = "/var/log/mail" },
      { name = "certificates2",      mount = "/opt/certs" },
      #{ name = "mysql2",            mount = "/var/mysql" },
      { name = "backup_mail_main",   mount = "/backup/mail/main" },
      { name = "backup_mail_other",  mount = "/backup/mail/other" },
      { name = "backup_mysql_main",  mount = "/backup/mysql/main" },
      { name = "backup_mysql_other", mount = "/backup/mysql/other" },
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
    roles = ["monitor", "bastion", "cert_user", "kubectl"],
    kubes         = ["kube"]
    local_volumes = []
    volumes = [
      { name = "certificates3", mount = "/opt/certs" }
    ]
  },
}


kube_apps = {
  "ox-8" = {
    services = ["webfront:8888"],
    targets  = ["sql_master:3306", "backup_sql:3307-3326", "mail_filter:783"],
    app      = "ox8",
    kube     = "kube",
  },
}

volumes = {
  # Pour main
  "maildir"      = { region = "main", size = 200, type = "high-speed" },
  "mysql1"       = { region = "main", size = 20,  type = "high-speed" },
  "logs"         = { region = "main", size = 50,  type = "classic"    },
  "certificates" = { region = "main", size = 5,   type = "classic"    },

  # Pour other
  "other_maildir" = { region = "main", size = 1, type = "classic" },
  "other_mysql"   = { region = "main", size = 1, type = "classic" },

  # Pour backup
  "maildir2"      = { region = "backup", size = 200, type = "classic" },
  "mysql2"        = { region = "backup", size = 20,  type = "classic" },
  "logs2"         = { region = "backup", size = 50,  type = "classic" },
  "certificates2" = { region = "backup", size = 5,   type = "classic" },

  # Pour backup2
  "backup_mail_main"   = { region = "backup", size = 1, type = "classic" },
  "backup_mail_other"  = { region = "backup", size = 1, type = "classic" },
  "backup_mysql_main"  = { region = "backup", size = 1, type = "classic" },
  "backup_mysql_other" = { region = "backup", size = 1, type = "classic" },

  "certificates3" = { region = "main", size = 5, type = "classic" }

  "certificates4" = { region = "main", size = 5, type = "classic" }
}

# Ces informations sont là pour que le fichier ressemble à Outscale, mais ne sont
# pas utilisées.
network_range = "10.100.0.0/16"

networks = {
  "main" = {
    "ip_range"  = "10.134.0.0/20" # 0.0 -> 15.255
    "region"    = "main"
    "is_public" = true
  }
  "backup" = {
    "ip_range"  = "10.134.16.0/20" # 16.0 -> 31.255
    "region"    = "backup"
    "is_public" = true
  }
  "main_priv" = {
    "ip_range"  = "10.134.32.0/20" # 32.0 -> 47.255
    "region"    = "main"
    "is_public" = false
  }
  "backup_priv" = {
    "ip_range"  = "10.134.48.0/20" # 48.0 -> 63.255
    "region"    = "backup"
    "is_public" = false
  }
}

# Private networks
global_private_networks = {
  "backend-network" = {
    vrack_vlan_id = 42
    cidr          = "172.21.0.0/16"
    new_bits      = 4
    regions       = [ "main", "backup", "GRA9", "SBG5", "RBX-A" ]
    dns_servers = [
      "213.186.33.99", # OVH default DNS
      "80.67.169.12",  # FDN
      "8.8.8.8",       # Google DNS
    ]
  }
}

private_network_name = "backend-network"
