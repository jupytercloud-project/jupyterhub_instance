
#!/usr/bin/env bash

set -x

export DEBIAN_FRONTEND=noninteractive

function main {
    #
    # '5be506bb-5284-4df2-a26d-88dcacf38161'
    #
    local -r persistent_volume_id="${1}"
    #
    # '/mnt/data;xfs'
    # '/mnt/data;zfs'
    #
    local -r persistent_volume_info="${2}"
    #
    # /mnt/data
    #
    local -r persistent_volume_mountpoint="$(
        printf '%s' "${persistent_volume_info}" \
      | cut -d';' -f1
    )"

    local -r persistent_volume_name="$(
        basename "${persistent_volume_mountpoint}"
    )"
    #
    # xfs
    #
    local -r persistent_volume_filesystem="$(
        printf '%s' "${persistent_volume_info}" \
      | cut -d';' -f2
    )"

    #
    # For a volume with ID 5be506bb-5284-4df2-a26d-88dcacf38161
    # Linux sees /dev/disk/by-id/virtio-5be506bb-5284-4df2-a
    #
    # cut -c -20: takes only the fist 20 characters of the ID
    #
    local -r disk_id="virtio-$(
        printf '%s' "${persistent_volume_id}" \
      | cut -c -20
    )"

    sudo mkdir -p "${persistent_volume_mountpoint}"

    case "${persistent_volume_filesystem}" in
        zfs)
            #
            # if the zpool command is missing, install it
            #
            if ! command -v 'zpool'; then
                sudo -E apt -y update
                sudo -E apt -y install zfsutils-linux
            fi
            #
            # import the pre-existing pools from the persistent volumes
            #
            sudo zpool import -a -f
            #
            # if no zpool pre-exist, create one
            #
            sudo zpool list -H "${persistent_volume_name}" \
         || sudo zpool create \
                       -m "${persistent_volume_mountpoint}" \
                       "${persistent_volume_name}" \
                       "/dev/disk/by-id/${disk_id}" \
            ;;
        *)

            #
            # For a mountpoint like '/var/log'
            # Create a unit name like 'var-log.mount'
            #
            # cut -c 2: remove first /
            # sed 's|/|-|g': replace '/' by '-'
            #
            local -r systemd_unit_name="$(
                printf '%s' "${persistent_volume_mountpoint}" \
              | cut -c 2- \
              | sed 's|/|-|g' \
            ).mount"

            sudo tee "/etc/systemd/system/${systemd_unit_name}" <<EOF
[Unit]
Description=Persistent Volume

[Mount]
What=/dev/disk/by-id/${disk_id}
Where=${persistent_volume_mountpoint}
Type=${persistent_volume_filesystem}

[Install]
WantedBy=multi-user.target
EOF

            sudo mkfs.${persistent_volume_filesystem} "/dev/disk/by-id/${disk_id}"
            sudo systemctl enable --now "${systemd_unit_name}"
            df -h
          ;;
    esac
}

main $@


