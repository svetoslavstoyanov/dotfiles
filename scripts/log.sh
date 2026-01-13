#!/usr/bin/env bash

GREEN="\e[32m"
YELLOW="\e[33m"
RESET="\e[0m"

log() { echo -e "${GREEN}==> $1${RESET}"; }
warn() { echo -e "${YELLOW}==> $1${RESET}"; }
