/*data "template_cloudinit_config" "cloudinit-vol" {
  gzip          = false
  base64_encode = false

  
  part {
    filename     = "user_data.sh"
    content_type = "text/x-shellscript"
    content = templatefile("${path.module}/templates/user_data.sh", { 
              DEVICE = var.inst_device_name,
              APP_VER = var.app_version,
              AWS_REG = var.aws_region,
              AWS_KEY = var.aws_key,
              AWS_SEC = var.aws_sec              
            })
  }

  part {
    filename     = "init.cfg"    
    content_type = "text/cloud-config"
    content = templatefile("${path.module}/scripts/init.cfg", { 
              REGION = var.aws_region
            })
  }
}
*/
