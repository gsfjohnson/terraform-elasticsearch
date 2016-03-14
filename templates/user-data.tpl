#!/bin/bash
set -e

## xxx: Ideally move all this to a proper config management tool

# Create es_vars
cat <<'EOF' >/tmp/es_vars
export CLUSTER_NAME="${es_cluster}"
export DATA_DIR="${es_datadir}"
export SECURITY_GROUPS="${aws_sg}"
export ES_ENV="${es_environment}"
export AVAILABILITY_ZONES="${aws_availability_zones}"
export AWS_REGION="${aws_region}"
EOF

# Configure service
cat <<'EOF' >/etc/elasticsearch/elasticsearch.yml
cluster.name: ${es_cluster}
network.host: _ec2:privateIpv4_
data.dir: ${es_datadir}
discovery.type: ec2
discovery.ec2.groups: ${aws_sg}
discovery.ec2.tag.es_env: ${es_environment}
cloud.aws.region: ${aws_region}
#cloud.node.auto_attributes: true
discovery.ec2.availability_zones: ${aws_availability_zones}
EOF

# Create datadir
sudo mkfs -t ext4 ${aws_ebs_volume_path}
sudo mkdir -p ${es_datadir}
sudo mount ${aws_ebs_volume_path} ${es_datadir}
sudo echo "${aws_ebs_volume_path} ${es_datadir} ext4 defaults,nofail 0 2" >> /etc/fstab
sudo chown -R elasticsearch:elasticsearch ${es_datadir}

# Start service
sudo chkconfig --add elasticsearch
sudo service elasticsearch start
