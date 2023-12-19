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
}