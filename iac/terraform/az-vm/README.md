# Basic Azure VM Terraform Configuration

This Terraform code provisions a small Linux VM environment in Azure.

## Prerequisites

You must have an SSH key generated and in the correct directory (`~/.ssh/id_ed25519.pub`). You must also be logged into Azure CLI (`az login`).

*This is a sandbox/testing deployment for demonstration purposes only, and proper best practices should be followed for production-grade deployments.*

## What this project does

- **`main.tf`**  
    Creates the core infrastructure:
    1. **Resource Group** (`terraform-rg01`)
    2. **Virtual Network** (`10.0.0.0/16`)
    3. **Subnet** (`10.0.1.0/24`)
    4. **Network Security Group** with inbound **SSH (port 22)** allowed
    5. **Public IP** (static)
    6. **Network Interface** connected to subnet + public IP
    7. **NSG association** to the NIC
    8. **Linux VM** (`terraform-vm01`) using Ubuntu 24.04 LTS image and SSH key auth

## Result

After `terraform apply` the public IP it output to the console, Azure deploys one Ubuntu VM reachable over SSH using the generated public IP output.
