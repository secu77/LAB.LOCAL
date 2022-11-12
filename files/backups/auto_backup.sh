#!/bin/bash

ssh vps "/srv/backup_containers.sh"
scp vps:/srv/backups/* ~/backups_infra/
find ~/backups_infra/ -type f -mtime +5 -delete
ssh vps "rm -f /srv/backups/*"
