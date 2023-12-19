
resource openstack_networking_port_v2 hub {
  name           = "hub"
  network_id     = data.openstack_networking_network_v2.private.id
  admin_state_up = "true"
}  