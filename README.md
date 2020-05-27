cd serverless-cms-admin;
git submodule update --init
cd vfg-field-array;
git pull
git checkout
cd -
cd forms-schema
git pull
git checkout
cd -
cd ..
mkdir -p serverless-cms-admin/selo/node_modules
mkdir -p serverless-cms-admin/vfg-field-array/node_modules
mkdir -p serverless-cms-admin/forms-schema/node_modules




serverless-cms-admin/config/dev.env.js
Unset.. to avoid multi-sites..  IS_WEBSITE_DEV
