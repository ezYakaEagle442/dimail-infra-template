# SSH keys
SSH keys are used to provision admin users on all instances.
Users are created from public keys name.
For example, `ssh_keys/coin` will create the `coin` user and push the public key in `/home/coin/.ssh/authorized_keys` on all hosts.
Ensure you are able to login without password with the key you add (passwordless or ssh-agent)

# DKIM keys
Good to know
- DKIM keys are used in `smtp_server` role.
- This role looks up for dkim keys with `/assets/dkim_keys/$DIMAIL_ENV/<domain>_<selector>.key` pattern
- For some command in this README, the working directory is `/assets/dkim_keys/`

### Important security warning
> **If, by mistake, you were to push an unencrypted DKIM key, it's a major security concern.**
> **Don't panic, consider it lost, delete it and generate a new one.**

### Generate a new DKIM key
To generate a new DKIM key (and its associated DNS record), choose between locally installed or docker-compose method below

#### Locally installed opendkim-genkey
how to install opendkim-genkey :
 - debian: `sudo apt-get install opendkim-utils`
 - nixos: `nix-shell -p opendkim`
 - ~~macos: `brew install libopendkim`~~
how to generate :
`opendkim-genkey -v -h sha256 -b 4096  --append-domain -s <selector> -d <domain>`


#### Alternative: docker-compose 
```bash
export DOMAIN="a.domain.numerique.gouv.fr"
export SELECTOR="aselector"
docker compose up
sudo cat ${SELECTOR}.txt > dkim_keys/${DOMAIN}_${SELECTOR}.txt
sudo cat ${SELECTOR}.private > dkim_keys/${DOMAIN}_${SELECTOR}.key
ansible-vault encrypt dkim_keys/${DOMAIN}_$SELECTOR.key
sudo rm -f $SELECTOR.txt
sudo rm -f $SELECTOR.private
```

#### Ensure the new key has the right name at the right place in an encrypted state
1. rename the generated files from `<selector>.private` to `<domain>_<selector>.key`
2. encrypt the `<domain>_<selector>.key` file with ansible-vault before pushing it to the repository
    ```
    ansible-vault encrypt --vault-password-file ../../40_ansible_single/vaultpasswd_file <domain>_<selector>.key 
    ```
3. finally, move these 2 files to the `$DIMAIL_ENV` directory, creating it if necessary



