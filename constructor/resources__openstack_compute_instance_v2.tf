resource openstack_compute_instance_v2 instance {
  name            = "jupyterhub"
  image_id        = data.openstack_images_image_v2.base_image.id
  flavor_name       = var.FLAVOR_NAME
  key_pair        = var.KEYPAIR_NAME
  security_groups = [data.openstack_networking_secgroup_v2.default.name,
                     data.openstack_networking_secgroup_v2.hub.name]
  network {
    port     = openstack_networking_port_v2.hub.id
  }

  #user_data = templatefile("${path.module}/user_data.tmpl", {
  #  fqdn = local.INSTANCE_FQDN
  #  timezone = local.TIMEZONE
  #  ntp_servers = local.NTP_SERVERS
  #  ssh_authorized_keys = data.external.ssh_authorized_keys.result
  #  ssh_host_keys = data.external.ssh_host_keys.result
  #})
  connection {
    type = "ssh"
    agent = true
    host = data.openstack_networking_floatingip_v2.hub.address
    user = var.REMOTE_USER
  }
  provisioner remote-exec {
    inline = [ "hostname" ]
  }
  #provisioner "local-exec" {
  #  environment = {
  #    REMOTE_USER = var.REMOTE_USER
  #    REMOTE_FQDN = data.openstack_networking_floatingip_v2.hub.address
  #  }
  #  working_dir = dirname(abspath(path.root))
  #  command = "pwd && task provisioner:install"
  #
  #}

}