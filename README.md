# COMP6452-IP-Management

## Overview
Smart contract to manage ownership of songs and licensing rights.

To run, ensure both servers are up using the commands listed below. 

This will provide a factory contract where the authorised user is able to deploy song smart contracts and designate managers for those contracts.

Payments need to be made in the exact amount of ethereum expected, any more or less will result in an error.

Since all development was done locally through Ganache, there is no addresses deployed publically and no address to provide for smart_contract_addresses.txt.

## API Server

Navigate to API folder

run `npm install`

then run `npm start`

## IP-Management Server

Navigate to IP-Management folder

`mkdir eth_providers && touch eth_providers/providers.json`

`mkdir eth_accounts && touch eth_accounts/accounts.json`

fill in providers and accounts

e.g.

```
{
    "provider_link": "ws://0.0.0.0:7545"
}
```

```
{
    "trusted_server": {
        "pri_key": ORACLE_ACCOUNT_PRIVATEKEY
    },
    "user": {
        "pri_key": USER_APP_ADMIN_ACCOUNT_PRIVATEKEY
    }
}
```

run `npm install`

To deploy the oracle contract: `npm start`

To deploy factory contract: `npm run deploy [oracle-address-from-previous-step]`

To listen to request: `npm run listen [oracle-address-from-previous-step]`
