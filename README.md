# COMP6452-IP-Management

## API Server

Navigate to API folder

run `npm install`

then run `npm start`

## IP-Management Server

Navigate to IP-Management folder

run `npm install`

To deploy the oracle contract: `npm start`

To deploy userapp contract: `npm run deploy [oracle-address-from-previous-step]`

To listen to request: `npm run listen [oracle-address-from-previous-step]`

To get address of an deployed Song oracle: `npm run invoke [userapp-address] search [sone title]`

To request a license purchase: `npm run invoke song [song-address] purchase [duration]`

To receive license hashcode: `npm run invoke song [song-address] receiveHashcode`

To request a license status check: `npm run invoke song [song-address] requestStatus [hashcode]`

To receive license status: `npm run invoke song [song-address] receiveStatus`
