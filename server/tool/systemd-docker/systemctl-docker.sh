#!/bin/bash

exec docker compose exec systemd systemctl "$@"