# Terraform_AWS_Glue_ELT_Pipeline
ELT Pipeline using AWS Glue with Terraform infrastructure configuration
# *Overview*
Project repo to demonstrate using Terraform to manage resource AWS S3 infrasture and utilize AWS Glue fot ELT Pipeline. Terraform is powerful tool to define, provision, manage cloud infrasture using code (Infrastucture as Code) with simple way. This project will create 3 S3 bucket: bucket-input -- data source, bucket-ouput -- result ETL, bucket-scripts -- ETL code palcing. ETL procress itself done in AWS Glue run. 
# *Prerequisites*
To follow along this project need to be availabled on system:
- AWS account
  Go to [aws.amazon.com](https://aws.amazon.com/) and create account
- Terraform installed
  ```bash
  wget -O - https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(grep -oP '(?  <=UBUNTU_CODENAME=).*' /etc/os-release || lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
  sudo apt update && sudo apt install terraform
  ```
- AWS cli installed
  ```bash
  curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
  unzip awscliv2.zip
  sudo ./aws/install
  ```
# *Project Flow*
1. Create a Working Directory
2. Initialize Terraform
3. Define Variables (Optional but Good Practice)
4. Create the ETL Script
5. Define Resources in Terraform
6. Plan and Apply
7. Run the ETL Pipeline
8. Cleanup (Important!)
