# Self-Hosted

> Work in progress...

Self-Hosted services over HTTPS for Raspberry Pi 4 Model B Server

## Requirements

- [Ansible](https://docs.ansible.com/ansible/2.10/installation_guide/) >= 2.10

To build the Packer image locally (commonly on Gnu+Linux):

- [Packer](https://www.packer.io/downloads) >= 1.7.0
- [Packer builder ARM](https://github.com/mkaczanowski/packer-builder-arm#quick-start) plugin for Packer

On MacOS, Windows 10 or when you just don't want to setup Packer and all the tools:

- [Docker](https://docs.docker.com/get-docker/) >= 20.10

## Build a custom OS image for Raspberry Pi

Pre-set packer sources available are:

- ArchLinux ARM armv7 (32-bit)
- ArchLinux ARM aarch64 (64-bit)

### Customize the image

Open and edit the `variables.pkrvars.hcl` file to customize all the desired values:

```sh
timezone    = "Etc/UTC"           # Default timezone for the system
locale      = "en_US.UTF-8"       # Default locale for the system
keymap      = "us"                # Default keyboard layout to use
net_address = "192.168.0.1/24"    # Static IPv4 or IPv6 address + prefix length
net_gateway = "192.168.0.254"     # Router / Gateway address
hostname    = "alarmpi"           # Custom machine hostname
username    = "alarm"             # Default user (`alarm` is Arch Linux ARM default)
auth_sshkey = "~/.ssh/id_rsa.pub" # Local path to public key. Used to SSH access the RPi
```

### Build image with Packer

Build the image using the latest available release:

```sh
$ sudo packer build -var-file="variables.pkrvars.hcl" packer/aarch64/
```

### Build in Docker (MacOS/Windows)

When there's no native way to use qemu-user-static (MacOS or Windows 10) the image can be built using Docker:

```sh
$ docker run --rm --privileged \
  -v /dev:/dev -v ${PWD}:/build \
  packer-builder-arm build \
  -var-file="variables.pkrvars.hcl" packer/aarch64/
```

On Windows 10, the command above should be executed into a WSL2 console.

## Flashing the image

On GNU+Linux it's a very straightforward process:

```sh
$ umount /dev/sdX*
$ dd if=custom-rpi.img of=/dev/sdX
```

where `/dev/sdX` is the device that represents your SD Card.

Another simple multiplatform tool is [Balena Etcher](https://www.balena.io/etcher/) available for Windows 10, MacOS and GNU+Linux.

![Balena Etcher](https://i.stack.imgur.com/b3VOr.gif)

Now put the SD Card into your Raspberry Pi 4 and **Power On**.

## Access from the local network

When your machine is up and ready, it should be accessible via SSH using the above assigned static IP address (`net_address` variable), or using `hostname.local` where `hostname` is the custom assigned hostname.

```sh
$ ssh -i <path/to/id_rsa> alarm@192.168.0.1
```

## Ansible: configure and manage the Raspberry Pi

First of all, install the required collections and roles on your working machine:

```sh
$ ansible-galaxy install -r requirements.yml
```
