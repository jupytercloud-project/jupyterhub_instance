output tags {
    value = data.openstack_networking_floatingip_v2.hub.all_tags
}
output floating_ip {
    value = data.openstack_networking_floatingip_v2.hub.address
}
