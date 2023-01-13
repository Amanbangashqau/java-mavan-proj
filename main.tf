 provider "aws" {
   region = "eu-central-1"
 }
 
 resource "tls_private_key" "terrafrom_generated_private_key" {
   algorithm = "RSA"
   rsa_bits  = 4096
 }
 
 resource "aws_key_pair" "generated_key" {
 
   # Name of key: Write the custom name of your key
   key_name   = "aws_keys_pairs"
 
   # Public Key: The public will be generated using the reference of tls_private_key.terrafrom_generated_private_key
   public_key = tls_private_key.terrafrom_generated_private_key.public_key_openssh
 
   # Store private key :  Generate and save private key(aws_keys_pairs.pem) in current directory
   provisioner "local-exec" {
     command = <<-EOT
       echo '${tls_private_key.terrafrom_generated_private_key.private_key_pem}' > aws_keys_pairs.pem
       chmod 400 aws_keys_pairs.pem
     EOT
   }
 }
 
 # 1. EC2 Instance 
 resource "aws_instance" "ec2_example" {
 
   ami = "ami-0767046d1677be5a0"
   instance_type = "t2.micro"

   # 2. Key Name
   # Specify the key name and it should match with key_name from the resource "aws_key_pair"
   key_name= "aws_keys_pairs"
   tags = {
     Name = "Terraform EC2 - using tls_private_key module"
   }
   vpc_security_group_ids = [aws_security_group.maingroup.id]
   user_data = file("file.sh")
   
   
   #3. Connection Block-
   connection {
     type        = "ssh"
     host        = self.public_ip
     user        = "ubuntu"
     
     # Mention the exact private key name which will be generated 
     private_key = file("aws_keys_pairs.pem")
     timeout     = "4m"
   }
 }

 resource "aws_security_group" "maingroup" {
  egress = [
    {
      cidr_blocks      = ["0.0.0.0/0"]
      description      = ""
      from_port        = 0
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "-1"
      security_groups  = []
      self             = false
      to_port          = 0
    }
  ]
  ingress = [
    {
      cidr_blocks      = ["0.0.0.0/0", ]
      description      = ""
      from_port        = 22
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "tcp"
      security_groups  = []
      self             = false
      to_port          = 22
    },
    {
      cidr_blocks      = ["0.0.0.0/0", ]
      description      = ""
      from_port        = 80
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "tcp"
      security_groups  = []
      self             = false
      to_port          = 80
    }
  ]
}