# mcServer-sysadmin

## Overview

This project automates the setup of a Minecraft server on AWS. The pipeline handles cloud infrastructure, server software configuration, and booting/shutdown of the server.

The entire pipeline can be run with a single script call (`run.sh`):

1. **Infrastructure Provisioning (Terraform)**: Creates the EC2 instance, security group, and Elastic IP for AWS.
2. **Server Configuration (Ansible)**: Connects to the instance over SSH and installs Java, downloads the Minecraft server JAR, accepts the EULA, and configures a `systemd` service to manage the server process.

## Requirements

### Tools

Terraform (v1.15.6) `brew install hashicorp/tap/terraform`
Ansible (core 2.21.0) `brew install ansible`

> These instructions are written for macOS .

### AWS Credentials

This project uses AWS Academy Learner Lab credentials, which expire at the end of each session. Before running the pipeline:

1. Start your Learner Lab session in Canvas
2. Click **AWS Details**, **Show** next to **AWS CLI**
3. Copy the three credential values into `terraform/terraform.tfvars`:

```hcl
aws_access_key    = "..."
aws_secret_key    = "..."
aws_session_token = "..."
```

### SSH Key

Download the Learner Lab PEM file:

1. In the Learner Lab module, click **Download PEM**
2. Save it as `vockey.pem` to the root folder
3. Set the correct permissions:

```bash
chmod 400 vockey.pem
```

### Configuration

Fill in the remaining values in `terraform/terraform.tfvars`:

```hcl
aws_region    = "us-east-1"
instance_type = "t2.medium"
key_name      = "vockey"
your_ip       = "x.x.x.x/32"  # run: curl ifconfig.me
```

---

## Running the script

From the project root, run:

```bash
chmod +x run.sh
./run.sh
```

The script will:

1. Run `terraform init` and `terraform apply` to begin the AWS server
2. Get server's public IP from Terraform output and write it to `ansible/inventory.ini`
3. Wait for SSH to become available on the instance
4. Run the Ansible playbook to configure the server

When complete, the script prints:

```
-- Done! Connect to your Minecraft server at: $SERVER_IP:25565 --
```

### Tearing Down

To destroy all AWS resources:

```bash
cd terraform
terraform destroy -auto-approve
```

---

## Connecting to the Minecraft Server

Once the script completes:

1. Open **Minecraft: Java Edition** (version 1.21.1)
2. Select **Multiplayer**, **Add Server**
3. Enter the IP printed by `run.sh` as the server address
4. Click **Done**, then select the server and join

To verify the server is reachable without Minecraft:

```bash
nmap -sV -Pn -p T:25565 <server_ip>
```

---

## Other info

### Server Shutdown

The `systemd` service includes an `ExecStop` directive that sends `SIGINT` to the Minecraft server process, triggering a graceful shutdown that saves the world state before stopping. This was a known issue with the previous manual setup which lacked a proper stop signal.

### No `user_data`

Server configuration is handled entirely by Ansible rather than the EC2 `user_data` field, which is considered bad practice as it makes configuration harder to debug, version, and rerun.

### Credential Management

AWS credentials and the SSH key are gitignored and never committed to github. The `terraform.tfvars` file is listed in `.gitignore`.

---

## Sources

- [Terraform AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Ansible Documentation](https://docs.ansible.com/)
- [Minecraft Server Download](https://www.minecraft.net/en-us/download/server)
- [AWS EC2 User Guide](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/)
- [systemd Service Documentation](https://www.freedesktop.org/software/systemd/man/systemd.service.html)
- [GitHub Repository](https://github.com/tateanders/mcServer-sysadmin)
