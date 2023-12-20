resource openstack_networking_floatingip_associate_v2 hub {
  floating_ip = data.openstack_networking_floatingip_v2.hub.address
  port_id     = openstack_networking_port_v2.hub.id
}