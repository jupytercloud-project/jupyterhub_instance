resource openstack_compute_volume_attach_v2 volume1 {
  instance_id = openstack_compute_instance_v2.instance.id
  volume_id   = data.openstack_blockstorage_volume_v3.volume1.id
}