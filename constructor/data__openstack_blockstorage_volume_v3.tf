data openstack_blockstorage_volume_v3 persistent-volumes {
  for_each = local.PERSISTENT_VOLUMES_NAME
  name = each.value
}