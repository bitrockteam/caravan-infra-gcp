#! /bin/bash

curl -sSO https://dl.google.com/cloudagents/add-monitoring-agent-repo.sh
sudo bash add-monitoring-agent-repo.sh

sudo yum install -y stackdriver-agent

sudo service stackdriver-agent start