#!/bin/bash

cd $HOME;
ln -snf /data/node_modules
cd /data;
for d in $(find . -mindepth 1 -maxdepth 1 -type d | grep -v \.git | grep -v node_modules); do
   cd /data/$d;
   ln -snf /data/node_modules
   if [ -e package.json ]; then
      echo "Will run npm install from $(pwd)"
      if [ ! -e /data/.no_npm_install ]; then
         npm install
      fi;
   fi;
done;
cd /data/grapejs-web-editor;
npm start dev & 
cd /data/serverless-cms-admin;
npm run dev &
cd /data/serverless-sample-hugosite;
if [ -e /data/hugo ]; then
   ../hugo serve --bind 0.0.0.0 --forceSyncStatic --destination public --enableApi=true --enableDev=true &
else
   hugo serve --bind 0.0.0.0 --forceSyncStatic --destination public --enableApi=true &
fi;
/usr/bin/atom -f
