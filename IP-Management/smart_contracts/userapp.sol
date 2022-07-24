// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "./oracle.sol";

contract UserApp is LicenseAgreementOracleClient {
    constructor(address oracleAd) LicenseAgreementOracleClient(oracleAd) {}
}
