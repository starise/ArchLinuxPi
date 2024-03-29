# A build block invokes sources and runs provisioning steps on them.
# https://www.packer.io/docs/from-1.5/blocks/build
build {
    sources = ["source.arm.provisioner"]

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
    # Initialize pacman keyring and populate Arch Linux ARM
    provisioner "shell" {
        inline = [
            "mv /etc/resolv.conf /etc/resolv.conf.bk",
            "echo 'nameserver 1.1.1.1' > /etc/resolv.conf",
            "echo 'nameserver 8.8.8.8' >> /etc/resolv.conf",
            "pacman-key --init",
            "pacman-key --populate archlinuxarm",
            "pacman -Syy --noconfirm --needed"
        ]
    }
    # Apply Raspberry Pi OS kernel tweaks
    provisioner "shell" {
        inline = [
            "echo 'kernel.printk = 3 4 1 3' > /etc/sysctl.d/98-rpi.conf",
            "echo 'vm.min_free_kbytes = 16384' >> /etc/sysctl.d/98-rpi.conf"
        ]
    }
    # Enable container features in the kernel
    provisioner "shell" {
        inline = [
            "printf %s \"$(cat /boot/cmdline.txt)\" > /boot/cmdline.txt",
            "echo \" cgroup_enable=cpuset cgroup_memory=1 cgroup_enable=memory\" >> /boot/cmdline.txt"
        ]
    }
    # Install custom utility packages
    provisioner "shell" {
        inline = [
            "pacman -S btrfs-progs parted --noconfirm --needed",
            "pacman -S bash-completion --noconfirm --needed",
            "pacman -S python --noconfirm --needed",
            "pacman -S sudo --noconfirm --needed",
            "pacman -S wget --noconfirm --needed",
            "pacman -S git --noconfirm --needed",
            "pacman -S zip unzip --noconfirm --needed",
            "pacman -S htop lm_sensors --noconfirm --needed"
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
    # Set up ssh access and disable password authentication
    provisioner "shell" {
        inline = [
            "mkdir /home/${var.username}/.ssh/",
            "touch /home/${var.username}/.ssh/authorized_keys",
            "chmod 700 /home/${var.username}/.ssh/",
            "chmod 600 /home/${var.username}/.ssh/authorized_keys",
            "chown ${var.username}:${var.username} /home/${var.username}/.ssh/ /home/${var.username}/.ssh/*",
            "sed '/PasswordAuthentication/d' -i /etc/ssh/sshd_config",
            "echo  >> /etc/ssh/sshd_config",
            "echo 'PasswordAuthentication no' >> /etc/ssh/sshd_config"
        ]
    }
    # Copy ssh authorized key to server user's home folder
    provisioner "file" {
        destination = "/home/${var.username}/.ssh/authorized_keys"
        source = "${var.auth_sshkey}"
    }
    # Use nano as default text editor
    provisioner "shell" {
        inline = ["echo 'export VISUAL=\"nano\"\nexport EDITOR=\"nano\"' > /etc/profile.d/nano.sh"]
    }
    # Set up sudo permissions and settings
    provisioner "shell" {
        inline = [
            "echo 'Defaults env_keep += \"EDITOR\"' > /etc/sudoers.d/01-env-editor",
            "chmod 440 /etc/sudoers.d/01-env-editor",
            "echo '${var.username} ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/10-${var.username}-nopasswd",
            "chmod 440 /etc/sudoers.d/10-${var.username}-nopasswd"
        ]
    }
    # Restore resolv.conf managed by systemd-resolved
    provisioner "shell" {
        inline = [
        "rm -v /etc/resolv.conf",
        "mv -v /etc/resolv.conf.bk /etc/resolv.conf",
        ]
    }
}
