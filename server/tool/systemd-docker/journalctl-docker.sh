#!/bin/bash

exec docker compose exec systemd journalctl "$@"
