# Dockerfile examples for containerized systemd (mainly for test environments)
Strongly influenced by the work of [@AkihiroSuda][akihiro-suda]'s work found [here][akihiro-suda].
Some ideas from [@ifireball][ifireball] on how to manage Journald.

_**NOTE: To get the journal in Docker Logs, this container MUST be run with `-t`.**_ 

## Demo 1: interactive shell with `systemctl`

* The command (`/bin/bash`) specified as the argument of `docker run` is executed as the foreground job in the container.
* Workdir (`--workdir /usr`) is propagated
* Env vars (`-e FOO=hello`) are propagated
* The container shuts down when the command exits. The exit status code (`42`) is propagated.

```console
% packer build --timestamp-ui -var build_date=$(date -u +'%Y-%m-%dT%H:%M:%SZ') -var vcs_ref=$(git rev-parse --verify HEAD | cut -c1-8) -var docker_username="terradatum8automation" -var docker_password="G6#h592m8HWYBvXam0" systemd.json
% docker run -it --rm -v /sys/fs/cgroup:/sys/fs/cgroup:ro -v /var/run/docker.sock:/var/run/docker.sock --cap-add=SYS_ADMIN --device=/dev/fuse --workdir /usr -e FOO=hello terradatum/systemd:bionic /bin/bash
Created symlink /etc/systemd/system/default.target → /lib/systemd/system/multi-user.target.
Created symlink /etc/systemd/system/multi-user.target.wants/docker-entrypoint.service → /etc/systemd/system/docker-entrypoint.service.
/docker-entrypoint.sh: starting /lib/systemd/systemd --show-status=false --unit=docker-entrypoint.target
systemd 237 running in system mode. (+PAM +AUDIT +SELINUX +IMA +APPARMOR +SMACK +SYSVINIT +UTMP +LIBCRYPTSETUP +GCRYPT +GNUTLS +ACL +XZ +LZ4 +SECCOMP +BLKID +ELFUTILS +KMOD -IDN2 +IDN -PCRE2 default-hierarchy=hybrid)
Detected virtualization docker.
Detected architecture x86-64.
Set hostname to <ed34e2e49886>.
Couldn't move remaining userspace processes, ignoring: Input/output error
File /lib/systemd/system/systemd-journald.service:36 configures an IP firewall (IPAddressDeny=any), but the local system does not support BPF/cgroup based firewalling.
Proceeding WITHOUT firewalling in effect! (This warning is only shown for the first loaded unit using IP firewalling.)
+ source /etc/docker-entrypoint-cmd
++ /bin/bash
root@ed34e2e49886:/usr# systemctl status
● ed34e2e49886
    State: running
     Jobs: 0 queued
   Failed: 0 units
    Since: Wed 2020-04-29 23:53:28 UTC; 9s ago
   CGroup: /system.slice/docker.service
           ├─init.scope
           │ └─1 /lib/systemd/systemd --show-status=false --unit=docker-entrypoint.target
           └─system.slice
             ├─networkd-dispatcher.service
             │ └─36 /usr/bin/python3 /usr/bin/networkd-dispatcher --run-startup-triggers
             ├─systemd-journald.service
             │ └─29 /lib/systemd/systemd-journald
             ├─docker-entrypoint.service
             │ ├─38 /bin/bash -exc source /etc/docker-entrypoint-cmd
             │ ├─41 /bin/bash
             │ ├─48 systemctl status
             │ └─49 pager
             ├─systemd-resolved.service
             │ └─35 /lib/systemd/systemd-resolved
             ├─dbus.service
             │ └─37 /usr/bin/dbus-daemon --system --address=systemd: --nofork --nopidfile --systemd-activation --syslog-only
             └─systemd-logind.service
               └─39 /lib/systemd/systemd-logind
root@ed34e2e49886:/usr# pwd
/usr
root@ed34e2e49886:/usr# echo $FOO 
hello
root@ed34e2e49886:/usr# exit 42
exit
zsh: exit 42    docker run -it --rm -v /sys/fs/cgroup:/sys/fs/cgroup:ro -v    --workdir /usr 
```

## Demo 2: `journalctl -f`

```console
% docker run -it --rm -v /sys/fs/cgroup:/sys/fs/cgroup:ro -v /var/run/docker.sock:/var/run/docker.sock --cap-add=SYS_ADMIN --device=/dev/fuse terradatum/systemd:bionic journalctl -f
Created symlink /etc/systemd/system/default.target → /lib/systemd/system/multi-user.target.
Created symlink /etc/systemd/system/multi-user.target.wants/docker-entrypoint.service → /etc/systemd/system/docker-entrypoint.service.
/docker-entrypoint.sh: starting /lib/systemd/systemd --show-status=false --unit=docker-entrypoint.target
systemd 237 running in system mode. (+PAM +AUDIT +SELINUX +IMA +APPARMOR +SMACK +SYSVINIT +UTMP +LIBCRYPTSETUP +GCRYPT +GNUTLS +ACL +XZ +LZ4 +SECCOMP +BLKID +ELFUTILS +KMOD -IDN2 +IDN -PCRE2 default-hierarchy=hybrid)
Detected virtualization docker.
Detected architecture x86-64.
Set hostname to <0520be24456a>.
Couldn't move remaining userspace processes, ignoring: Input/output error
File /lib/systemd/system/systemd-journald.service:36 configures an IP firewall (IPAddressDeny=any), but the local system does not support BPF/cgroup based firewalling.
Proceeding WITHOUT firewalling in effect! (This warning is only shown for the first loaded unit using IP firewalling.)
+ source /etc/docker-entrypoint-cmd
++ journalctl -f
-- Logs begin at Wed 2020-04-29 23:55:49 UTC. --
Apr 29 23:55:49 0520be24456a systemd[1]: Reached target System Initialization.
Apr 29 23:55:49 0520be24456a systemd[1]: Listening on D-Bus System Message Bus Socket.
Apr 29 23:55:49 0520be24456a systemd[1]: Starting Dispatcher daemon for systemd-networkd...
Apr 29 23:55:49 0520be24456a systemd[1]: Started D-Bus System Message Bus.
Apr 29 23:55:49 0520be24456a systemd[1]: Started docker-entrypoint.service.
Apr 29 23:55:49 0520be24456a systemd[1]: Starting Login Service...
Apr 29 23:55:49 0520be24456a systemd[1]: Starting Permit User Sessions...
Apr 29 23:55:49 0520be24456a systemd[1]: systemd-journald.service: Failed to add fd to store: Operation not permitted
Apr 29 23:55:49 0520be24456a systemd[1]: systemd-journald.service: Failed to add fd to store: Operation not permitted
Apr 29 23:55:49 0520be24456a systemd[1]: systemd-journald.service: Failed to add fd to store: Operation not permitted
Apr 29 23:55:49 0520be24456a systemd[1]: Started Permit User Sessions.
Apr 29 23:55:49 0520be24456a systemd-logind[39]: New seat seat0.
Apr 29 23:55:49 0520be24456a systemd[1]: Started Login Service.
Apr 29 23:55:49 0520be24456a systemd-resolved[35]: Positive Trust Anchors:
Apr 29 23:55:49 0520be24456a systemd-resolved[35]: . IN DS 19036 8 2 49aac11d7b6f6446702e54a1607371607a1a41855200fd2ce1cdde32f24e8fb5
Apr 29 23:55:49 0520be24456a systemd-resolved[35]: . IN DS 20326 8 2 e06d44b80b8f1d39a95c0b0d7c65d08458e880409bbc683457104237c7f8ec8d
Apr 29 23:55:49 0520be24456a systemd-resolved[35]: Negative trust anchors: 10.in-addr.arpa 16.172.in-addr.arpa 17.172.in-addr.arpa 18.172.in-addr.arpa 19.172.in-addr.arpa 20.172.in-addr.arpa 21.172.in-addr.arpa 22.172.in-addr.arpa 23.172.in-addr.arpa 24.172.in-addr.arpa 25.172.in-addr.arpa 26.172.in-addr.arpa 27.172.in-addr.arpa 28.172.in-addr.arpa 29.172.in-addr.arpa 30.172.in-addr.arpa 31.172.in-addr.arpa 168.192.in-addr.arpa d.f.ip6.arpa corp home internal intranet lan local private test
Apr 29 23:55:49 0520be24456a systemd-resolved[35]: Using system hostname '0520be24456a'.
Apr 29 23:55:49 0520be24456a systemd[1]: Started Network Name Resolution.
Apr 29 23:55:49 0520be24456a systemd[1]: Reached target Host and Network Name Lookups.
Apr 29 23:55:49 0520be24456a networkd-dispatcher[36]: No valid path found for iwconfig
Apr 29 23:55:49 0520be24456a networkd-dispatcher[36]: No valid path found for iw
Apr 29 23:55:49 0520be24456a networkd-dispatcher[36]: WARNING: systemd-networkd is not running, output will be incomplete.
Apr 29 23:55:49 0520be24456a systemd[1]: Started Dispatcher daemon for systemd-networkd.
Apr 29 23:55:49 0520be24456a systemd[1]: Reached target the target for docker-entrypoint.service.
Apr 29 23:55:49 0520be24456a systemd[1]: Startup finished in 342ms.
^Cgot signal INT
zsh: exit 130   docker run -it --rm -v /sys/fs/cgroup:/sys/fs/cgroup:ro -v     journalctl -f
```

## Bugs
* `docker run` needs `-t`

[akihiro-suda]: https://github.com/AkihiroSuda
[akihiro-suda]: https://github.com/AkihiroSuda/containerized-systemd
[ifireball]: https://github.com/ifireball/systemd-base/tree/logs-and-args/etc/systemd
