#!/bin/bash

containers_path="/srv/containers"
volumes_path="/srv/data"
backups_path="/srv/backups"

# Iterate over containers path and export images of every service
for service in $(ls $containers_path); do

    docker_compose_path="$containers_path/$service/docker-compose.yml"
    if test -f $docker_compose_path; then

        mkdir -p $backups_path/$service
        outfile="${backups_path}/${service}/${service}_images.tar"

	    echo -e "[+] Exporting images from $service..."

        # Save images from docker-compose file
        docker save -o $outfile $(docker-compose -f $docker_compose_path config | awk '{if ($1 == "image:") print $2;}') &>/dev/null
    fi
done


# Iterate over volumes path and store contents of every service
for service in $(ls $volumes_path); do

    echo -e "[+] Store volumes from $service..."
    mkdir -p $backups_path/$service
    tar -czvf "${backups_path}/${service}/${service}_volumes.tar.gz" $volumes_path/$service &>/dev/null
done


# Iterate over backups path and pack every service files in path
for service in $(ls $backups_path); do

    echo -e "[+] Packing backups files from $service..."
    date=$(date '+%Y%m%d_%H%M%S')
    tar -czvf "${backups_path}/${date}_${service}_backup.tar.gz" $backups_path/$service &>/dev/null

    echo -e "[+] Done! Clearing backups files from $service..."
    rm -rf $backups_path/$service
done
