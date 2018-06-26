cd src
yarn

if [ ! -d build ] ;then mkdir build; fi
cp main.js build/main.js

if [ -d build/node_modules ] ;then rm -rf build/node_modules; fi
cp -R node_modules/ build/node_modules/

cd build && zip -rq aws-lambda-image.zip .
mkdir release
mv build/aws-lambda-image.zip ../release/
