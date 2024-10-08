# docker scripts files

## docker_npm_wan_update.sh

### Description
Update the Access list of the Nginx Proxy Manager in a docker container with the latest public IP. Especialy usuful for all the Self hosting folks on dynamic IPs.

Idea for the script from [NPM Issue 1708](https://github.com/NginxProxyManager/nginx-proxy-manager/issues/1708#issuecomment-1975058359)

### Requirement
  1. Current user docker rights
  2. Crontab configuration
  3. NPM access list should already have WAN IP configured

### Setup:
  1. Create file directory: `mkdir wanip`
  2. Download script `wget https://github.com/spacecake/docker_scripts/raw/refs/heads/main/docker_npm_wan_update.sh`
  3. Give executable permission `chmod +x docker_npm_wan_update.sh`
    or

```
  mkdir wanip && wget -O wanip/docker_npm_wan_update.sh https://github.com/spacecake/docker_scripts/raw/refs/heads/main/docker_npm_wan_update.sh && chmod +x wanip/docker_npm_wan_update.sh && cd wanip
```

  5. *IMPORTANT* Edit and change variables: folders, log files and your npm docker container location and name:
       ```
     nano docker_npm_wan_update.sh
       ```
  7. Edit user crontab:
     * If you are in you $HOME folder, then the path for the script is /home/username/wanip/docker_npm_wan_update.sh
     * Crontab is your friend, how to configure look at https://crontab.guru/
     
     Example: run every 15min. How to set default editor from corntab outside of scoope. Check article at  https://www.howtogeek.com/410995/how-to-change-the-default-crontab-editor/
     
       ```
     crontab -e
       ```
     
     Add a line with enter at the end:
     
       ```
     */15 * * * * /home/username/wanip/docker_npm_wan_update.sh >/dev/null 2>&1
       ```
     
     Note " >/dev/null 2>&1" is to stop the cronjob sending email every 15 minutes.

