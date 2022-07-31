#!/bin/bash

# Iniciando updates iniciais e configuraçao do 

sudo apt-get update -y && sudo apt-get upgrade -y
sudo apt-get install apt-transport-https openjdk-8-jre-headless uuid-runtime pwgen -y
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 9DA31620334BD75D9DCB49F368818C72E52529D4

# Iniciando a instalação do mongo

echo "deb [ arch=amd64 ] https://repo.mongodb.org/apt/ubuntu bionic/mongodb-org/4.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-4.0.list
sudo apt-get update
sudo apt-get install -y mongodb-org

# Reiniciando o serviço do mongo

sudo systemctl enable mongod.service
sudo systemctl restart mongod.service

# Iniciando a instalação do elasticsearch

wget -q https://artifacts.elastic.co/GPG-KEY-elasticsearch -O myKey
sudo apt-key add myKey
echo "deb https://artifacts.elastic.co/packages/oss-7.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-7.x.list
sudo apt-get update -y && sudo apt-get install elasticsearch-oss -y
sudo tee -a /etc/elasticsearch/elasticsearch.yml > /dev/null <<EOT
cluster.name: graylog
action.auto_create_index: false
EOT

# Reiniciando o serviço do elasticsearch

sudo systemctl daemon-reload
sudo systemctl enable elasticsearch.service
sudo systemctl restart elasticsearch.service

# Iniciando a instalação do Graylog Server

wget https://packages.graylog2.org/repo/packages/graylog-4.1-repository_latest.deb
sudo dpkg -i graylog-4.1-repository_latest.deb
sudo apt-get update -y && sudo apt-get install graylog-server graylog-enterprise-plugins graylog-integrations-plugins graylog-enterprise-integrations-plugins -y

# Inserindo a senha GRAYLOG no server.conf

senha=$(echo -n "graylog" | sha256sum | cut -d" " -f1)
sed -i 's/root_password_sha2 =/root_password_sha2 = '$senha'/' /etc/graylog/server/server.conf
sed -i 's/password_secret =/password_secret = '$senha'/' /etc/graylog/server/server.conf
echo "http_bind_address = 0.0.0.0:9000" >> /etc/graylog/server/server.conf

# Fim da inserção e iniciando o serviço do graylog

sudo systemctl daemon-reload
sudo systemctl enable graylog-server.service
sudo systemctl start graylog-server.service

clear

echo "

Acesso WEB

URL: IP:9000

Usuario: graylog
Senha: graylog
"
