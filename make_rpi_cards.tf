locals {
  /* Change this to your local SDcard path */
  sdcard_path     = "/dev/disk4" 

  /* Change this to your local SDcard path */
  image           = "ubuntu-22.04-preinstalled-server-armhf+raspi.img"

  gateway = "192.168.10.254"
  nameservers = "[1.1.1.1, 8.8.8.8]"
  fqdn = "local"

  public_key    = file("~/.ssh/id_rsa.pub")

	rpi = [
		{
			name 	= "rpi-01"
			ip		= "192.168.10.150"
			tag		= "master"
			user	= "ubuntu"
			desc	= "RPI 2b+"
		},
		{
			name 	= "rpi-02"
			ip		= "192.168.10.151"
			tag		= "agent"
			user	= "ubuntu"
			desc	= "RPI 2b+"
		}
	]
}

/* Create cloud-init user-data files from template*/
resource "local_file" "user-data" {
  for_each = {for vm in local.rpi:  vm.name => vm}
  content = templatefile(
    "${path.module}/templates/user-data.tftpl",
    { 
      name  = each.value.name
      hostname  = each.value.name
      fqdn = local.fqdn
      public_key = local.public_key
      ip  =  each.value.ip
      gateway = local.gateway
      nameservers = local.nameservers
    }
 )
 filename = "cloud-init/user-data-${each.value.name}"
}

/* Create counter for wait loop */
resource "null_resource" "set_initial_state" {
  depends_on = [local_file.user-data]
  provisioner "local-exec" {
    interpreter = ["bash", "-c"]
    command     = "echo \"0\" > initial_state"
  }
}

/* Write RPI images with cloud-init to SDcards*/
resource "null_resource" "sdcard_creation_wait" {

  depends_on = [null_resource.set_initial_state]
  /* count      = length(local.rpi) */
  count = length(local.rpi)
  /* for_each = {for vm in local.rpi:  vm.index => vm} */
  provisioner "local-exec" {
    interpreter = ["bash", "-c"]
    command     = "while [[ $(cat initial_state) != \"${count.index}\" ]]; do echo \"${local.rpi[count.index].name} is asleep...\";((c++)) && ((c==180)) && break;sleep 10;done"
  }

  provisioner "local-exec" {
    interpreter = ["bash", "-c"]
        command     = "while [[ $(diskutil list | grep ${local.sdcard_path}) != '${local.sdcard_path} (external, physical):' ]]; do echo \"${count.index} needs SD card...\";((c++)) && ((c==180)) && break;sleep 10;done"
  }

  provisioner "local-exec" {
    command = "flash -d ${local.sdcard_path} -f -u cloud-init/user-data-${local.rpi[count.index].name} ${local.image}"
  }

  provisioner "local-exec" {
    interpreter = ["bash", "-c"]
    command     = "echo \"${count.index + 1}\" > initial_state"
  }
}