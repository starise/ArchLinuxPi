# A build block invokes sources and runs provisioning steps on them.
# https://www.packer.io/docs/from-1.5/blocks/build
build {
    sources = ["source.arm.provisioner"]

    provisioner "shell" {
        inline = [
            "pacman-key --init",
            "pacman-key --populate archlinuxarm",
            "mv /etc/resolv.conf /etc/resolv.conf.bk",
            "echo 'nameserver 1.1.1.1' > /etc/resolv.conf",
            "echo 'nameserver 8.8.8.8' >> /etc/resolv.conf",
            "pacman -Sy --noconfirm --needed",
            "pacman -S parted --noconfirm --needed"
        ]
    }
    # Upload scripts/resizerootfs to /tmp
    provisioner "file" {
        destination = "/tmp"
        source      = "scripts/resizerootfs"
    }
    # Set up rootfs resize for first boot
    provisioner "shell" {
        script = "scripts/bootstrap_resizerootfs.sh"
    }
    # Set server timezone
    provisioner "shell" {
        inline = ["ln -sf /usr/share/zoneinfo/${var.timezone} /etc/localtime"]
    }
    # Set keyboard layout
    provisioner "shell" {
        inline = ["echo 'KEYMAP=${var.keymap}' > /etc/vconsole.conf"]
    }
    # Set server locale
    provisioner "shell" {
        inline = [
            "echo 'LANG=${var.locale}' > /etc/locale.conf",
            "sed -i -e '/^[^#]/s/^/#/' -e '/${var.locale}/s/^#//' /etc/locale.gen",
            "locale-gen ${var.locale}"
        ]
    }
    # Set static wired network
    provisioner "shell" {
        inline = [
            "echo '[Match]' > /etc/systemd/network/eth0.network",
            "echo 'Name=eth0\n' >> /etc/systemd/network/eth0.network",
            "echo '[Network]' >> /etc/systemd/network/eth0.network",
            "echo 'Address=${var.net_address}' >> /etc/systemd/network/eth0.network",
            "echo 'Gateway=${var.net_gateway}' >> /etc/systemd/network/eth0.network"
        ]
    }
    # Set up static table lookup for hostnames
    provisioner "shell" {
        inline = [
            "echo '${var.hostname}' > /etc/hostname",
            "echo '127.0.0.1 localhost' >> /etc/hosts",
            "echo '127.0.1.1 ${var.hostname}' >> /etc/hosts",
            "echo '::1       ip6-localhost ip6-loopback' >> /etc/hosts",
            "echo 'fe00::0   ip6-localnet' >> /etc/hosts",
            "echo 'ff00::0   ip6-mcastprefix' >> /etc/hosts",
            "echo 'ff02::1   ip6-allnodes' >> /etc/hosts",
            "echo 'ff02::2   ip6-allrouters' >> /etc/hosts",
            "echo 'ff02::3   ip6-allhosts' >> /etc/hosts"
        ]
    }
}
