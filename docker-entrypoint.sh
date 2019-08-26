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

export WORKDIR=/data;
echo "Home is ${WORKDIR}"

PERM=$(stat -c %u /data/serverless-cms-admin/node_modules)
if [ ${PERM} -eq 0 ]; then
  chown ${USER}: /data/serverless-cms-admin/node_modules
fi
mkdir -p /data/serverless-cms-admin/vfg-field-array/node_modules 2> /dev/null
mkdir -p /data/serverless-cms-admin/selo/node_modules 2> /dev/null
if [ -e /data/serverless-cms-admin/vfg-field-array/node_modules ]; then
  PERM=$(stat -c %u /data/serverless-cms-admin/vfg-field-array/node_modules)
  if [ ${PERM} -eq 0 ]; then
    mkdir -p /data/serverless-cms-admin/vfg-field-array/node_modules
    chown ${USER}: /data/serverless-cms-admin/vfg-field-array/node_modules
  fi
  mkdir -p /data/serverless-cms-admin/node_modules/vfg-field-array/node_modules
  chown ${USER}: /data/serverless-cms-admin/node_modules/vfg-field-array/node_modules
  chown ${USER}: /data/serverless-cms-admin/selo/node_modules
fi

# cd /data/serverless-cms-admin/ && npm link vfg-field-array
# cd /data/serverless-cms-admin/ && npm link selo
# # ln -snf /data/serverless-cms-admin/vfg-field-array /data/node_modules/vfg-field-array
# # ln -snf /data/serverless-cms-admin/selo /data/node_modules/selo
# 
mkdir -p /data/serverless-cms-admin/node_modules/selo/node_modules
chown -R ${USER}: /data/serverless-cms-admin/node_modules/selo
chown -R ${USER}: /data/serverless-cms-admin/node_modules/vfg-field-array

cd /data;
# [ -e /data/.npm ] && rm -fr /data/.npm
mkdir -p /home/${USER}/.npm && chown ${USER}: /home/${USER}/.npm
chmod guo+rwx /home/${USER}/.npm
[ -e node_modules ] && chown ${USER}: node_modules
[ -e /data/serverless-cms-admin/vfg-field-array/.babelrc ] && rm -f /data/serverless-cms-admin/vfg-field-array/.babelrc
#mkdir -p /data/.npm/_cacache
#chown -R ${USER} /data/.npm

su -m ${USER} /bin/bash -c "
whoami
cd /data;
echo \"NODE PTH IS \${NODE_PATH}\"
export NODE_PATH=\"${NODE_PATH}\"
cd \$WORKDIR;
for d in \$(find . -mindepth 1 -maxdepth 1 -type d | grep -v .git | grep -v node_modules); do
   cd /data/\$d;
   # [ -e node_modules ] && rm -fr node_modules;
   # ln -snf /data/node_modules
   if [ -e package.json ]; then
      echo 'Will run npm install from \$(pwd)'
      #if [ ! -e /data/.no_npm_install ]; then
      #   npm install
      #fi;
      [ ! -e /data/node_modules/.completed ] && npm install
   fi;
done;
#cd /data/grapejs-web-editor;
#npm i
#npm start dev & 
cd /data/serverless-cms-admin;
# cd vfg-field-array && npm i && npm run build && cd -
[ ! -e /data/node_modules/.completed ] && npm i -S vfg-field-array
[ ! -e /data/node_modules/.completed ] && npm i -S selo
[ ! -e /data/node_modules/.completed ] && npm i
touch /data/node_modules/.completed
# ./buildSelo.sh
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
