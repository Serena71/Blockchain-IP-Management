# COMP6452-IP-Management

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
