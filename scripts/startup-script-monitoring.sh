#! /bin/bash

sudo service stackdriver-agent start

sudo sysctl -w vm.max_map_count=262144

sudo systemctl enable prometheus
sudo systemctl start prometheus
sudo systemctl enable elasticsearch
sudo systemctl start elasticsearch
sudo systemctl enable grafana
sudo systemctl start grafana
