#!/bin/bash

# Update system packages
sudo yum update -y

# ------------------------------
# Install Docker
# ------------------------------
sudo amazon-linux-extras install docker -y
#sudo yum install -y docker
sudo systemctl start docker
sudo systemctl enable docker

# Add ec2-user to docker group to run docker without sudo
sudo usermod -aG docker ec2-user

# ------------------------------
# Install Docker Compose (v2+)
# ------------------------------
DOCKER_COMPOSE_VERSION="v2.24.5"
sudo curl -SL https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m) \
  -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# ------------------------------
# Install CloudWatch Agent
# ------------------------------
sudo yum install -y amazon-cloudwatch-agent

# ------------------------------
# Create CloudWatch Agent Config
# ------------------------------
sudo tee /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json > /dev/null <<EOF
{
  "metrics": {
    "append_dimensions": {
      "InstanceId": "\${aws:InstanceId}"
    },
    "metrics_collected": {
      "cpu": {
        "measurement": [
          "cpu_usage_idle",
          "cpu_usage_user",
          "cpu_usage_system"
        ],
        "metrics_collection_interval": 60,
        "totalcpu": true
      },
      "disk": {
        "measurement": ["used_percent"],
        "resources": ["*"],
        "metrics_collection_interval": 60
      },
      "mem": {
        "measurement": ["mem_used_percent"],
        "metrics_collection_interval": 60
      }
    }
  }
}
EOF
