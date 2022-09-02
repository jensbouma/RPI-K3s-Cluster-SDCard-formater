# Terraform RPI SDCard Creator
This plan is made to easly provision a RPI cluster. The script writes the amount of SD cards as defined in the local variables for the inital RPI setup.

**Use install_tools.sh to install the following tools on the local machine**
- Brew
- Terraform
- Flash + pv
- Python3 + pip

**Edit the following variables in the local varibles in the tf file**
- **sdcard_path**, the exact path for your SDcard slot
- **image**, path of the RPI image (ubuntu server for cloud-init)
- **Public Key path**
- **RPI list**, list with IP's for the RPI's
- **gateway**, the gateway adress
- **nameservers** the nameservers

### Stage 1: Provisioning SD-Cards within Terraform Plan:

* **terraform init**    Initialize terraform
* **terraform plan**    See what the plan is
* **sudo terraform apply**   Creates the SD Cards for number of hosts in the rpi variabale. (needs sudo for writing SDCard, make sure path is OK!!!)

### Notes:
- The network config is in bridge mode to connect my Huawei 4G Hotspot, this can be changed in the templatefile.
- This plan is tested on MacOS.
