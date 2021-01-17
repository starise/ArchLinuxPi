# Source blocks are generated from builders; a source can be referenced in build blocks.
# A build block runs provisioner and post-processors on a source.
# https://www.packer.io/docs/from-1.5/blocks/source
source "arm" "provisioner" {
    file_checksum_type    = "md5"
    file_checksum_url     = "http://os.archlinuxarm.org/os/ArchLinuxARM-rpi-4-latest.tar.gz.md5"
    file_target_extension = "tar.gz"
    file_unarchive_cmd    = ["bsdtar", "-xpf", "$ARCHIVE_PATH", "-C", "$MOUNTPOINT"]
    file_urls             = ["http://os.archlinuxarm.org/os/ArchLinuxARM-rpi-4-latest.tar.gz"]
    image_build_method    = "new"
    image_path            = "${local.timestamp}-rpi4.img"
    image_size            = "2G"
    image_type            = "dos"
    image_partitions {
        filesystem   = "vfat"
        mountpoint   = "/boot"
        name         = "boot"
        size         = "256M"
        start_sector = "2048"
        type         = "c"
    }
    image_partitions {
        filesystem   = "ext4"
        mountpoint   = "/"
        name         = "root"
        size         = "0"
        start_sector = "526336"
        type         = "83"
    }
    qemu_binary_destination_path = "/usr/bin/qemu-arm-static"
    qemu_binary_source_path      = "/usr/bin/qemu-arm-static"
}
