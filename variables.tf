### MANDATORY ###

variable "owner_tag" {
  description = "Who owns the instance."
}

variable "environment_tag" {
  description = "Whether instance is production, test, development, etc."
  default = "Development"
}

variable "billing_tag" {
  description = "Billing information for instance."
  default = "n/a"
}

variable "application_tag" {
  description = "Application tag."
  default = "elasticsearch"
}

variable "customer_tag" {
  description = "Customer"
  default = "n/a"
}

#variable "environment" {
#  default = "default"
#}

#variable "es_environment" {
#  default = "elasticsearch"
#}

variable "es_cluster" {
  default = "elasticsearch"
}

###################################################################
# AWS configuration below
###################################################################
variable "key_name" {
  description = "Name of the SSH keypair to use in AWS."
  default = "elastic"
}

### MANDATORY ###
variable "aws_region" {
  description = "AWS region to launch servers."
  default = "us-west-2"
}

variable "aws_availability_zones" {
  description = "AWS region to launch servers."
  default = "us-west-2a,us-west-2b"
}

variable "security_group_name" {
  description = "Name of security group to use in AWS."
  default = "app-elasticsearch"
}

variable "iam_role_name" {
  description = "Name of the IAM Role applied to the EC2 instances."
  default = "app-role-elasticsearch"
}

variable "iam_role_policy_name" {
  description = "Name of the IAM Role Policy applied to the EC2 instances."
  default = "app-policy-elasticsearch"
}

variable "iam_instance_profile_name" {
  description = "Name of IAM instance profile."
  default = "app-iam-ip-elasticsearch"
}

###################################################################
# Vpc configuration below
###################################################################

### MANDATORY ###
variable "vpc_id" {
  description = "VPC id"
}

variable "internal_cidr_blocks"{
  default = "0.0.0.0/0"
}

###################################################################
# Subnet configuration below
###################################################################

### MANDATORY ###
variable "subnets" {
  description = "subnets to deploy into"
}

###################################################################
# Elasticsearch configuration below
###################################################################

### MANDATORY ###
# Amazon Linux built by packer
# See https://github.com/nadnerb/packer-elastic-search
variable "ami" {
}

variable "instance_type" {
  description = "Elasticsearch instance type."
  default = "t2.medium"
}

### MANDATORY ###
# if you have multiple clusters sharing the same es_environment..?
variable "es_cluster" {
  description = "Elastic cluster name"
}

### MANDATORY ###
variable "es_environment" {
  description = "Elastic environment tag for auto discovery"
}

# total number of nodes
variable "instances" {
  description = "total instances"
  default = "2"
}

#DEPRECATED
# number of nodes in zone a
variable "subnet_a_num_nodes" {
  description = "Elastic nodes in a"
  default = "1"
}

#DEPRECATED
# number of nodes in zone b
variable "subnet_b_num_nodes" {
  description = "Elastic nodes in b"
  default = "1"
}

# the ability to add additional existing security groups. In our case
# we have consul running as agents on the box
variable "additional_security_groups" {
  default = ""
}

variable "aws_ebs_volume_path" {
  default = "/dev/xvda"
}

variable "aws_ebs_volume_size" {
  default = "10"
}

variable "aws_ebs_volume_encryption" {
  default = true
}

variable "es_datadir" {
  description = "Elasticsearch data directory."
  default = "/opt/elasticsearch/data"
}
