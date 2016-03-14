provider "aws" {
  region = "${var.aws_region}"
}

##############################################################################
# Elasticsearch
##############################################################################

resource "aws_iam_instance_profile" "elasticsearch" {
  name = "${var.iam_instance_profile_name}"
  roles = ["${aws_iam_role.elasticsearch.name}"]
}

resource "aws_iam_role_policy" "elasticsearch" {
  name = "${var.iam_role_policy_name}"
  role = "${aws_iam_role.elasticsearch.id}"
  policy = <<EOF
{
  "Statement": [
    {
      "Action": [
        "ec2:DescribeInstances"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ],
  "Version": "2012-10-17"
  }
EOF
}

resource "aws_iam_role" "elasticsearch" {
    name = "${var.iam_role_name}"
    assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_security_group" "elasticsearch" {
  name = "${var.security_group_name}"
  description = "Elasticsearch ports with ssh"
  vpc_id = "${var.vpc_id}"

  # SSH access from anywhere
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["${split(",", var.internal_cidr_blocks)}"]
  }

  # elastic ports from anywhere.. we are using private ips so shouldn't
  # have people deleting our indexes just yet
  ingress {
    from_port = 9200
    to_port = 9400
    protocol = "tcp"
    cidr_blocks = ["${split(",", var.internal_cidr_blocks)}"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

#  tags {
#    Name = "${var.es_cluster}-elasticsearch"
#    cluster = "${var.es_cluster}"
#  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "template_file" "user_data" {
  template = "${path.module}/templates/user-data.tpl"

  vars {
    num_nodes               = "${var.instances}"
    aws_ebs_volume_path     = "${var.aws_ebs_volume_path}"
    es_datadir              = "${var.es_datadir}"
    es_cluster              = "${var.es_cluster}"
    es_environment          = "${var.es_environment}"
    aws_sg                  = "${aws_security_group.elasticsearch.id}"
    aws_region              = "${var.aws_region}"
    aws_availability_zones  = "${var.aws_availability_zones}"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_launch_configuration" "elasticsearch" {
  image_id = "${var.ami}"
  instance_type = "${var.instance_type}"
  security_groups = ["${split(",", replace(concat(aws_security_group.elasticsearch.id, ",", var.additional_security_groups), "/,\\s?$/", ""))}"]
  associate_public_ip_address = false
  ebs_optimized = false
  key_name = "${var.key_name}"
  iam_instance_profile = "${aws_iam_instance_profile.elasticsearch.id}"
  user_data = "${template_file.user_data.rendered}"

  lifecycle {
    create_before_destroy = true
  }

  ebs_block_device {
    device_name = "${var.aws_ebs_volume_path}"
    volume_size = "${var.aws_ebs_volume_size}"
#    encrypted = "${var.aws_ebs_volume_encryption}"
  }
}

resource "aws_autoscaling_group" "elasticsearch" {
  availability_zones = ["${split(",", var.aws_availability_zones)}"]
  vpc_zone_identifier = ["${split(",", var.subnets)}"]
  max_size = "${var.instances}"
  min_size = "${var.instances}"
  desired_capacity = "${var.instances}"
  default_cooldown = 30
  force_delete = true
  launch_configuration = "${aws_launch_configuration.elasticsearch.id}"

  tag {
    key = "Name"
    value = "${format("%s-elasticsearch", var.es_cluster)}"
    propagate_at_launch = true
  }
  tag {
    key = "Owner"
    value = "${var.owner_tag}"
    propagate_at_launch = true
  }
  tag {
    key = "Application"
    value = "${var.application_tag}"
    propagate_at_launch = true
  }
  tag {
    key = "Billing"
    value = "${var.billing_tag}"
    propagate_at_launch = true
  }
  tag {
    key = "Environment"
    value = "${var.environment_tag}"
    propagate_at_launch = true
  }
  tag {
    key = "Customer"
    value = "${var.customer_tag}"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}
