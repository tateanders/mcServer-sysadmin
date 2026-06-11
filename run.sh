#!/bin/bash
set -e

echo "-- Running Terraform --"
cd terraform
terraform init -input=false
terraform apply -auto-approve
SERVER_IP=$(terraform output -raw minecraft_server_ip)
cd ..

echo "-- Server IP: $SERVER_IP --"

echo "-- Updating Ansible inventory --"
cat > ansible/inventory.ini <<EOF
[minecraft]
$SERVER_IP ansible_user=ubuntu ansible_ssh_private_key_file=$(pwd)/vockey.pem
EOF

echo "-- Waiting for SSH to become available --"
until ssh -i vockey.pem -o StrictHostKeyChecking=no -o ConnectTimeout=5 ubuntu@$SERVER_IP 'exit' 2>/dev/null; do
    echo "SSH not ready yet, retrying in 10 seconds..."
    sleep 10
done

echo "-- Configuring server with Ansible --"
ansible-playbook -i ansible/inventory.ini ansible/playbook.yml \
    --ssh-extra-args="-o StrictHostKeyChecking=no"

echo "-- Done! Connect to your Minecraft server at: $SERVER_IP:25565 --"