
resource null_resource setup-base {
  depends_on = [
    openstack_compute_volume_attach_v2.persistent-volumes
  ]
  connection {
    type  = "ssh"
    agent = true
    host  = data.openstack_networking_floatingip_v2.hub.address
    user  = var.REMOTE_USER
  }
  provisioner file {
    source = "remote/scripts/base/setup.bash"
    destination = "/tmp/setup-base.bash"
  }

  provisioner remote-exec {
    inline = [
      "bash /tmp/setup-base.bash"
    ]
  }
} 

resource null_resource setup-persistent-volume {
  depends_on = [
    openstack_compute_volume_attach_v2.persistent-volumes
  ]

  for_each = data.openstack_blockstorage_volume_v3.persistent-volumes

  connection {
    type  = "ssh"
    agent = true
    host  = data.openstack_networking_floatingip_v2.hub.address
    user  = var.REMOTE_USER
  }

  provisioner file {
    source = "remote/scripts/persistent-volume/setup.bash"
    destination = "/tmp/setup-persistent-volume.bash"
  }

  provisioner remote-exec {
    inline = [
      "bash /tmp/setup-persistent-volume.bash '${each.value.id}' '${each.key}'"
    ]
  }
}

resource null_resource exec-provisioner-tasks {
  depends_on = [
    null_resource.setup-persistent-volume
  ]

  provisioner local-exec {
    command = "bash local/scripts/exec_provisioner_tasks.bash"
  }
}
