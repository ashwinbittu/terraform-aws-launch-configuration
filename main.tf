resource "null_resource" "test-setting-variables" {
    provisioner "local-exec" {
        command = "echo ${var.aws_key} : ${var.aws_sec}"
    }
}



data "aws_ami" "repave_images" {
  #most_recent = true
  #filter {
  #  name   = "name"
  #  values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"]
  #}
  #filter {
  #  name   = "virtualization-type"
  #  values = ["hvm"]
  #}
  #owners = ["099720109477"] # Canonical
    
  filter {
    name   = "name"
    values = ["repave-ami-${var.app_version}.0"]
  }
  owners = ["109769995951"] # Canonical
}

resource "aws_launch_configuration" "hatest" {
  #name_prefix     = "hatest-${var.app_color}-" 
  name_prefix     = "hatest-" 
  image_id        = data.aws_ami.repave_images.id
  instance_type   = var.inst_type
  key_name        = var.aws_ec2_keypair_name
  security_groups = var.aws_security_group_instances_id 
  user_data = data.template_cloudinit_config.cloudinit-vol.rendered

  root_block_device {
      volume_size           = "10"
      volume_type           = "gp2"
      delete_on_termination = true
    }
 
  ebs_block_device {
      device_name           = var.inst_device_name
      #snapshot_id           = var.aws_ebs_snap_id
      snapshot_id           = var.aws_ebs_snap_id == "" ? "" : var.aws_ebs_snap_id
      volume_type           = var.aws_ebs_volume_type == "" ? "gp2" : var.aws_ebs_volume_type
      volume_size           = var.aws_ebs_volume_size == "" ? "10" : var.aws_ebs_volume_size
      #delete_on_termination = false
    }  
  lifecycle {
    create_before_destroy = true
  } 
}


