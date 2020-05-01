#!/bin/bash
###
# Originally: https://github.com/AkihiroSuda/containerized-systemd/blob/master/docker-entrypoint.sh
set -e
container=docker
export container

systemctl set-default multi-user.target
systemctl mask systemd-firstboot.service
systemctl unmask systemd-logind

if [ $# -ne 0 ]; then

  env >/etc/docker-entrypoint-env

  cat >/etc/systemd/system/docker-entrypoint.target <<EOF
[Unit]
Description=the target for docker-entrypoint.service
Requires=docker-entrypoint.service systemd-logind.service systemd-user-sessions.service
EOF

  quoted_args="$(printf " %q" "${@}")"
  echo "${quoted_args}" >/etc/docker-entrypoint-cmd

  standard_input=
  if [[ ! -t 0 ]]; then
    standard_input=null
  else
    standard_input="tty-force"
  fi

  cat >/etc/systemd/system/docker-entrypoint.service <<EOF
[Unit]
Description=docker-entrypoint.service

[Service]
ExecStart=/bin/bash -exc "source /etc/docker-entrypoint-cmd"
# EXIT_STATUS is either an exit code integer or a signal name string, see systemd.exec(5)
ExecStopPost=/bin/bash -ec "if echo \${EXIT_STATUS} | grep [A-Z] > /dev/null; then echo >&2 \"got signal \${EXIT_STATUS}\"; systemctl exit \$(( 128 + \$( kill -l \${EXIT_STATUS} ) )); else systemctl exit \${EXIT_STATUS}; fi"
StandardInput=$standard_input
StandardOutput=inherit
StandardError=inherit
WorkingDirectory=$(pwd)
EnvironmentFile=/etc/environment
EnvironmentFile=/etc/docker-entrypoint-env

[Install]
WantedBy=multi-user.target
EOF

  systemctl enable docker-entrypoint.service

  systemd_args="--show-status=false --unit=docker-entrypoint.target"

else

  systemd_args="--system"

fi

systemd=
if [ -x /lib/systemd/systemd ]; then
  systemd=/lib/systemd/systemd
elif [ -x /usr/lib/systemd/systemd ]; then
  systemd=/usr/lib/systemd/systemd
elif [ -x /sbin/init ]; then
  systemd=/sbin/init
else
  echo >&2 'ERROR: systemd is not installed'
  exit 1
fi

echo "$0: starting $systemd $systemd_args"
exec $systemd $systemd_args
