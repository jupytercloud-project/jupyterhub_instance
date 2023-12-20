output REMOTE_FQDN {
    value = data.openstack_networking_floatingip_v2.hub.address
}
output REMOTE_USER {
    value = var.REMOTE_USER
}