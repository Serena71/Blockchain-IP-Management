// SPDX-License-Identifier: UNLICENSED;
// Copy of code to be copy and pasted onto remix.

pragma solidity >=0.8.00 <0.9.0;
import "remix_tests.sol"; 
import "remix_accounts.sol";
import "../contracts/factory.sol";
import "https://github.com/GNSPS/solidity-bytes-utils/blob/master/contracts/BytesLib.sol";

abstract contract FactoryTest{
    using BytesLib for bytes;

    // Variables used to emulate different accounts
    address acc0 ;
    address acc1 ;
    address acc2 ;
    address acc3 ;
    address acc4 ;

    Factory f ;

    /// 'beforeAll' runs before all other tests
    function beforeAll() public {
        acc0 = TestsAccounts . getAccount(0) ; // Initiate account variables
        acc1 = TestsAccounts . getAccount(1) ;
        acc2 = TestsAccounts . getAccount(2) ;
        acc3 = TestsAccounts . getAccount(3) ;
        acc4 = TestsAccounts . getAccount(4) ;
        f = new Factory(0x8853AB7F8b49deB480fDA4D90d31B1eA76fb02Ab);
    }

    /// Function addSong with account 1 as a song managermanager
    /// When msg.sender is not specified the default account will be set as sender
    function addSongSuccess() public {
        f.addSong("BeatIt",acc1,100);
    }

    /// Function addSong failure try to add song other than as a manager
    /// #sender: account-2
    function addSongFailure() public {
        (bool success, bytes memory result) = address(f).delegatecall(abi.encodeWithSignature("addSong(string, address, uint)","BeatIt","acc1","100"));
        if(success == false) {
            string memory reason = abi.decode(result.slice(4,result.length - 4),(string));
            Assert.equal(reason,"New song can only be deployed by the authorised node","Failed with unexpected reason");
        } else {
            Assert.ok(false,"Method execution should fail");
        }

    }
    
    /// Function addArtist failure try to add artist other than as a song manager
    /// #sender: account-2
    function addArtistFailure () public {
        (bool success, bytes memory result) = address(f).delegatecall(abi.encodeWithSignature("addArtist(string, address,string,uint)","Jackson","acc4","singer","50"));
        if(success == false) {
            string memory reason = abi.decode(result.slice(4,result.length - 4),(string));
            Assert.equal(reason,"This function can only be accessed by song manager","Failed with unexpected reason");
        } else {
            Assert.ok(false,"Method execution should fail");
        }
    }
}