#! /bin/sh

if [ ! -f /etc/gentoo-release ]; then
    echo "Must be Gentoo"
    exit
fi

if [ "`id -u`" != "0" ]; then
    echo "Must be root!"
    exit
fi

if [ -d /usr/local/portage ]; then
    echo "/usr/local/portage already exists!"
    exit
fi

mkdir -p /usr/local/portage/{metadata,profiles}
hostname > /usr/local/portage/profiles/repo_name
echo "masters = gentoo" > /usr/local/portage/metadata/layout.conf
chown -R portage:portage /usr/local/portage
# Allow non-root portage group users to put ebuilds to local overlay
chmod g+w /usr/local/portage

echo "PORTDIR_OVERLAY=\"/usr/local/portage \${PORTDIR_OVERLAY}\"" >> /etc/portage/make.conf

