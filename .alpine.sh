#!/bin/sh
# Alpine (Raspberry Pi): fish and starship for the user running this through doas.
# Clone the repo as that user first, then: doas ./.alpine.sh
set -eu
cd "$(dirname "$0")"

if [ "$(id -u)" -ne 0 ] || [ -z "${DOAS_USER:-}" ]; then
    echo "Run it through doas from your own account: doas ./.alpine.sh"
    exit 1
fi
user="$DOAS_USER"

# fish and starship live in the community repository
main_repo=$(grep -m1 '^http.*/main$' /etc/apk/repositories)
community_repo="${main_repo%/main}/community"
grep -qx "$community_repo" /etc/apk/repositories || echo "$community_repo" >>/etc/apk/repositories

# bash runs scripts/install.sh, shadow provides chsh, tzdata makes TZ=Europe/Berlin work
apk add -U fish starship bash git github-cli shadow tzdata

su -l -s /bin/sh "$user" -c "cd '$PWD' && ./scripts/install.sh"

grep -qx /usr/bin/fish /etc/shells || echo /usr/bin/fish >>/etc/shells
chsh -s /usr/bin/fish "$user"
echo "Done. Log in again, or run: exec fish"
