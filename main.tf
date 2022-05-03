terraform {
  required_providers {
    libvirt = {
      source = "dmacvicar/libvirt"
      version = "0.6.14"
    }
  }
}

# 
# export LIBVIRT_DEFAULT_URI="qemu+ssh://root@192.168.1.100/system"
# the user must be a member of the libvirt group on the kvm server
# and the security_driver must be adjusted as per 
# https://github.com/dmacvicar/terraform-provider-libvirt/issues/546#issuecomment-612983090
# 
provider "libvirt" {
  # Configuration options
  uri = "qemu+ssh://tfuser:terraform@mjmenger-NUC10i5FNH/system?sshauth=ssh-password&known_hosts_verify=ignore"
}

resource libvirt_volume volterra-base {
    name   = "volterra_base"
    source = "https://vesio.blob.core.windows.net/dev/images/centos/7.2009.10-202106210938/vsb-ves-ce-certifiedhw-generic-production-centos-7.2009.10-202106210938.1624275431.iso"
}

# Define KVM domain to create
resource "libvirt_domain" "f5xc_ce" {
  name   = "customer-edge"
  memory = 16384
  vcpu   = 4

  network_interface {
    network_name = "default" # List networks with virsh net-list
  }

  disk {
    volume_id = libvirt_volume.volterra-base.id
  }

  console {
    type = "pty"
    target_type = "serial"
    target_port = "0"
  }

  graphics {
    type = "spice"
    listen_type = "address"
    autoport = true
  }
}

# Output Server IP
# this does not work as desired
output "ip" {
  value = libvirt_domain.f5xc_ce.network_interface.0.addresses
}