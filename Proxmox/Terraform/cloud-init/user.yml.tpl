#cloud-config
hostname: ${hostname}
fqdn: ${fqdn}
manage_etc_hosts: true

package_update: true
package_upgrade: true
packages:
  - curl
  - wget
  - vim
  - htop
  - net-tools
  - iotop
  - git
  - unzip
  - python3-pip
  - fail2ban

runcmd:
  - systemctl enable fail2ban
  - systemctl start fail2ban
  - echo "Setup complete" > /var/log/setup-complete.log
