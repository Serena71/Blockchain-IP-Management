# COMP6452-IP-Management

## API Server
Navigate to API folder

run `npm install`

then run `npm start`


## IP-Management Server
Navigate to IP-Management folder

run `npx tsc`

run `node build/index.js deploy oracle` to deployer oracle

run `node build/index.js deploy userapp [oracle-address-from-previous-step]` to deploy userapp

run `node build/index.js listen oracle [oracle-address-from-previous-step]` to listen to request
