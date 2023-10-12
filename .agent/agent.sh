#!/bin/sh

# Install required tools
repo_version=$(if command -v lsb_release &> /dev/null; then lsb_release -r -s; else grep -oP '(?<=^VERSION_ID=).+' /etc/os-release | tr -d '"'; fi)
curl -s https://packages.microsoft.com/config/ubuntu/$repo_version/packages-microsoft-prod.deb -o packages-microsoft-prod.deb
dpkg -i packages-microsoft-prod.deb
rm packages-microsoft-prod.deb
apt-get update
apt-get -y install unzip python3-pip python3-venv dotnet-sdk-7.0

# Create and configure user for agent
useradd -s /bin/bash -d /home/azdoagent -m azdoagent
mkdir /azp
chown -R azdoagent:azdoagent /azp

# Get AzDo agent
cd /azp
curl -s https://vstsagentpackage.azureedge.net/agent/3.220.5/vsts-agent-linux-x64-3.220.5.tar.gz -o agent.tar.gz
tar xzf agent.tar.gz
rm agent.tar.gz

# Configure the agent using the azdoagent user
aws_instance_id=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
sudo -u azdoagent ./config.sh --unattended --replace --acceptTeeEula --url "https://dev.azure.com/${azdo_org}" --auth "pat" --token "${azdo_pat}" --pool "${azdo_pool}" --agent "$aws_instance_id"

# Load environment variables
source /etc/environment

# Install and start the agent
./svc.sh install azdoagent
./svc.sh start