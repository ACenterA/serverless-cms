#!/bin/sh
set -x
export PATH="/usr/local/bin/:${PATH}"
# unset NODE_PATH
export PATH
export NODE_PATH

mkdir -p /usr/app
chmod o+rwx /usr /usr/app
chown ${USER}: /usr /usr/app
cd /usr/app/
[ -e package-lock.json ] && rm package*lock*

mkdir -p /usr/app/node_modules/
cp -Rf /usr/local/lib/node_modules/fibers /usr/app/node_modules/

find /usr/app/node_modules -not -user ${USER} -exec chown ${USER} {} \;

#cd /usr/app/serverless-cms-admin; rm -fr node_modules; ln -snf ../node_modules; cd -;
#cd /usr/app/serverless-cms-admin; rm -fr node_modules; ln -snf ../node_modules; cd -;
#cd /usr/app/serverless-cms-admin; mkdir -p rm -fr node_modules; ln -snf ../node_modules; cd -;
mkdir -p /usr/app/serverless-cms-admin/node_modules
mkdir -p /usr/app/serverless-cms-admin/selo/node_modules
chown ${USER}: /usr/app/serverless-cms-admin/selo/node_modules

cat > /tmp/.run <<EOF
export PATH="/usr/local/lib/node_modules/npm/bin/:${PATH}:/usr/app/node_modules/.bin"
mkdir -p /usr/app/node_modules
cd /usr/app/serverless-cms-admin/;
ls -atlrh
whoami
export PATH="/usr/local/bin/:${PATH}"
export PATH="${PATH}"
export NODE_PATH="${NODE_PATH}"
export NODE_ENV="${NODE_ENV}"
export IS_WEBSITE_DEV                                                                          
export API_URL                 
echo "1 - IS WEBSITE DEV: ${IS_WEBSITE_DEV} and.. ${API_URL}"
npm config set prefix "/usr/app/node_modules"
ls -latrh;
pwd
[ ! -e /usr/app/node_modules/.completed ] && npm i --no-audit 2>/dev/null;
mkdir -p /usr/app/node_modules
cp -Rf /usr/local/lib/node_modules/fibers /usr/app/node_modules/
(cd /usr/app/node_modules/fibers/; node-gyp configure; /usr/local/bin/node /usr/app/node_modules/fibers/build)
cd /usr/app/serverless-cms-admin;

mkdir -p /usr/app/serverless-cms-admin/vfg-field-array/node_modules 2> /dev/null
mkdir -p /usr/app/serverless-cms-admin/selo/node_modules 2> /dev/null
mkdir -p /usr/app/node_modules
mkdir -p /usr/app/serverless-cms-admin/node_modules/vfg-field-array/node_modules
[ -e vfg-field-array/.babelrc ] && rm -f vfg-field-array/.babelrc

cd /usr/app/serverless-cms-admin;
for d in \$(find . -mindepth 1 -maxdepth 1 -type d | grep -v .git | grep -v node_modules); do
   cd /usr/app/serverless-cms-admin/\$d;
   # [ -e node_modules ] && rm -fr node_modules;
   # ln -snf /usr/app/node_modules
   if [ -e package.json ]; then
      echo 'Will run npm install from \$(pwd)'
      #if [ ! -e /usr/app/.no_npm_install ]; then
      #   npm install
      #fi;
      [ ! -e /usr/app/node_modules/.completed ] && npm install
   fi;
   cd /usr/app/serverless-cms-admin;
done;

cd /usr/app/serverless-cms-admin;
[ ! -e /usr/app/node_modules/.completed ] && (cd vfg-field-array && npm i && npm run build:es && cd -)
[ ! -e /usr/app/node_modules/.completed ] && npm i -S vfg-field-array
[ ! -e /usr/app/node_modules/.completed ] && npm i -S selo
[ ! -e /usr/app/node_modules/.completed ] && npm i
touch /usr/app/node_modules/.completed


(cd /usr/app/serverless-cms-admin; watchexec -f 'package.json' --force-poll 5000 -i vue-ssr-client-manifest.json,babel.config.json,nodemon.json,package-lock.json,backend*,node_modules* --verbose -s SIGKILL -r 'echo Relaunching NPM i; cd /usr/app/serverless-cms-admin; [ -e package-lock.json ] && rm -f package-lock.json; npm i --prefer-offline --no-audit') &
cd /usr/app/serverless-cms-admin
npm run dev
$@
EOF
#yarn run build
# yarn run dev
# $@
chmod +x /tmp/.run
npm config set prefix "/usr/app/node_modules"

cd /usr/app;
[ -e node_modules/.cache/babel-loader ] && rm -rf node_modules/.cache/babel-loader

echo "WILL CREATE SYMLINK ln -snf /usr/app/postcss.config.js /usr/postcss.config.js"
export PATH="/usr/local/lib/node_modules/npm/bin/:${PATH}:/usr/app/node_modules/.bin"
export NODE_ENV
export IS_WEBSITE_DEV
export API_URL
echo "IS WEBSITE DEV: ${IS_WEBSITE_DEV} and.. ${API_URL}"

find /usr/ | grep node-gyp

exec /tmp/.run
