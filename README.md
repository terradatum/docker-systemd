# ubuntu-systemd
Docker ubuntu with systemd

## OCI System Hooks

http://www.projectatomic.io/

https://github.com/projectatomic/oci-systemd-hook
https://github.com/projectatomic/oci-register-machine

### PPA
sudo add-apt-repository ppa:projectatomic/ppa

## Minimal run comand

```shell script
docker run -it \
  --name=ubuntu-systemd \
  -v /sys/fs/cgroup:/sys/fs/cgroup:ro \
  --tmpfs /tmp \
  --tmpfs /run \
  --tmpfs /run/lock \
  terradatum/ubuntu-systemd:bionic
```

* Volumes noted above are **REQUIRED** to run this container with systemd.
* Recommended that the `/tmp`, `/run` and `/run/lock` mounts are `tmpfs`.

## Docker-in-dock run command

```shell script
docker run -it \
  --name=ubuntu-systemd \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v /sys/fs/cgroup:/sys/fs/cgroup:ro \
  --tmpfs /tmp \
  --tmpfs /run \
  --tmpfs /run/lock \
  terradatum/ubuntu-systemd:bionic
```
