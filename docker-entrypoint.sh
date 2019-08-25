#!/bin/bash

[ "${DEBUG}" = "true" ] && set -x
set +e
sed -ri "s/:$GID:/:88888:/g" /etc/group
sed -ri "s/:$UID:/:88888:/g" /etc/passwd


sed -ri "s/:$GID:/:88888:/g" /etc/group
sed -ri "s/:$UID:/:88888:/g" /etc/passwd

[ -e /etc/pam.d ] && echo auth     optional  pam_gnome_keyring.so >> /etc/pam.d/login
[ -e /etc/pam.d ] && echo session  optional  pam_gnome_keyring.so auto_start >> /etc/pam.d/login

USER=${USER:-'acentera'}
UID=${UID:-1000}
GID=${GID:-1000}
APP_HOME=/home/${USER}/
PASSWORD=${PASSWORD:-'acentera'}

if [ ! "X$(which useradd)" = "X" ]; then
  useradd --user-group --shell /bin/bash --home-dir "${APP_HOME}" --uid "$UID" "$USER"
else
  addgroup --gid "$GID" -S "${USER}" && adduser -s "/bin/bash" -g "" --uid "${UID}" -S "${USER}" -G "${USER}"
fi

mkdir -p "${APP_HOME}"
chown "$UID:$GID" "${APP_HOME}"
echo "${USER}:${PASSWORD}" | chpasswd 1> /dev/null 2>/dev/null && [ -e /usr/bin/sudo ] && adduser "${USER}" sudo  2>/dev/null || true
echo "root:$(pwgen -s)" | chpasswd 1>/dev/null 2>/dev/null || true

export USER UID GID APP_HOME
unset PASSWORD

echo "Home is ${HOME}"
cd $HOME;
aa

PERM=$(stat -c %u /data/serverless-cms-admin/node_modules)
if [ ${PERM} -eq 0 ]; then
  chown ${USER}: /data/serverless-cms-admin/node_modules
fi

su -m ${USER} /bin/bash -c "
HOME='${HOME}'
cd $HOME;
ln -snf /data/node_modules
cd /data;
for d in $(find . -mindepth 1 -maxdepth 1 -type d | grep -v \.git | grep -v node_modules); do
   cd /data/$d;
   ln -snf /data/node_modules
   if [ -e package.json ]; then
      echo 'Will run npm install from $(pwd)'
      #if [ ! -e /data/.no_npm_install ]; then
      #   npm install
      #fi;
      npm install
   fi;
done;
#cd /data/grapejs-web-editor;
#npm i
#npm start dev & 
cd /data/serverless-cms-admin;
npm i
npm run dev &
cd /data/serverless-sample-hugosite;
if [ -e /data/hugo ]; then
   ../hugo serve --bind 0.0.0.0 --forceSyncStatic --destination public --enableApi=true --enableDev=true &
else
   hugo serve --bind 0.0.0.0 --forceSyncStatic --destination public --enableApi=true &
fi;
# /usr/bin/atom -f
"

tail -f /dev/null
