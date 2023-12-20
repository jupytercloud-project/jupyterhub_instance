resource openstack_compute_volume_attach_v2 persistent-volumes {
  for_each    = data.openstack_blockstorage_volume_v3.persistent-volumes
  instance_id = openstack_compute_instance_v2.instance.id
  volume_id   = each.value.id
}