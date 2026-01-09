set -euo pipefail

GREEN="\e[32m"
YELLOW="\e[33m"
RED="\e[31m"
RESET="\e[0m"
log() { echo -e "${GREEN}==> $1${RESET}"; }
warn() { echo -e "${YELLOW}==> $1${RESET}"; }
err() { echo -e "${RED}==> $1${RESET}"; }
