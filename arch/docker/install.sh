#!/bin/bash

printf "\n===> Installing Docker\n\n"

yaourt -S docker
sudo systemctl start docker
sudo groupadd docker
sudo usermod -aG docker $USER
docker run hello-world

printf "\n===> Installing Docker Compose\n\n"

yaourt -S docker-compose



