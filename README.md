# Arch Linux on Raspberry Pi 4

Build and deploy a custom Arch Linux image for Raspberry Pi 4.

## Requirements

- [Ansible](https://docs.ansible.com/ansible/2.10/installation_guide/) >= 2.10
- [Packer](https://www.packer.io/downloads) >= 1.7.0
- [Packer builder ARM](https://github.com/mkaczanowski/packer-builder-arm#quick-start) plugin for Packer

```sh
# Required packages on Arch Linux host
$ yay -S ansible packer qemu qemu-extra qemu-arch-extra qemu-user-static-bin
```

The above packages are enough to build Packer images locally (commonly on Gnu/Linux). On MacOS, Windows 10 or when you just don't want to setup Packer and all the tools, Docker is also required:

- [Docker](https://docs.docker.com/get-docker/) >= 20.10

## Packer - Build custom Arch image for Raspberry Pi

Pre-set packer sources available are:

- ArchLinux ARM armv7 (32-bit)
- ArchLinux ARM aarch64 (64-bit)

Open and edit the `variables.pkrvars.hcl` file to customize all the desired values.

### Packer - Build image locally

Build the image using the latest available release:

```sh
$ sudo packer build -var-file="variables.pkrvars.hcl" packer/aarch64/
```

### Packer - Build image in Docker (MacOS/Windows)

When there's no native way to use qemu-user-static (MacOS or Windows 10) the image can be built using Docker:

```sh
$ docker run --rm --privileged \
  -v /dev:/dev -v ${PWD}:/build \
  packer-builder-arm build \
  -var-file="variables.pkrvars.hcl" packer/aarch64/
```

On Windows 10, the command above should be executed into a WSL2 console.

### Flashing the image on the SD Card

On GNU+Linux it's a very straightforward process:

```sh
# `/dev/sdX` is the device that represents your SD Card
$ umount /dev/sdX*
$ dd if=custom-rpi.img of=/dev/sdX
```

Another simple multiplatform tool to flash the image is [Balena Etcher](https://www.balena.io/etcher/) available for Windows 10, MacOS and GNU+Linux.

When done, put the SD Card into your Raspberry Pi 4 and **Power On** the device.

## Access to Raspberry Pi from the local network

When your machine is up and ready, it should be accessible via SSH using the assigned static IP address (`net_address` variable), or using `hostname.local` where `hostname` is the assigned hostname.

```sh
$ ssh -i <path/to/id_rsa> alarm@192.168.0.1
```

## Ansible - Configure the system

Install required collections and roles:

```sh
$ ansible-galaxy install -r requirements.yml
```

Open and edit `group_vars/*.yml` files to customize the desired values. Once you have made the desired changes, let's configure the system via Ansible running the `system.yml` playbook:

```sh
$ ansible-playbook system.yml
```
