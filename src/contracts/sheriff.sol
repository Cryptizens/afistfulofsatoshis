pragma solidity ^0.4.19;

/*
   Sheriff contract for A fistful of Satoshis Western shooter
*/

import "github.com/oraclize/ethereum-api/oraclizeAPI.sol";

contract Sheriff is usingOraclize {

    event enteredCallback(bytes32);
    event newRandomNumber_bytes(bytes);
    event newRandomNumber_uint(uint);
    event outlawKilled(address);
    event innocentKilled(address);

    // the amount at stake for killing the outlaw, starts at 0
    uint public reward = 0;
    // the amount to pay to the Sheriff to play (in Wei, equal to 0.25 ETH)
    uint public minimumStake = 250000000000000000;
    // record the queries made by each player
    mapping (bytes32 => address) queriesMapping;
    // withdrawal logic
    mapping (address => uint) pendingWithdrawals;

    function Sheriff() {
      // Constructor function, not used for anything specific yet
    }

    // Fallback function to increase the reward
    function () payable {
        reward += msg.value;
    }

    // the callback function is called by Oraclize when the result is ready
    function __callback(bytes32 _queryId, string _result) public {
        require (msg.sender == oraclize_cbAddress());
        enteredCallback(_queryId);

        newRandomNumber_bytes(bytes(_result)); // this is the resulting random number (bytes)

        // for simplicity of use, let's also convert the random bytes to uint if we need
        uint randomNumber = uint(keccak256(_result)) % 3; // this is an efficient way to get the uint out in the [0, maxRange] range

        newRandomNumber_uint(randomNumber); // this is the resulting random number (uint)

        address playerAddress = queriesMapping[_queryId];
        // the player is lucky and has killed the outlaw !
        if (randomNumber == 0) {
          // Broadcast the event
          outlawKilled(playerAddress);
          // Transfer the full reward to the lucky player
          pendingWithdrawals[playerAddress] += reward;
          // Reset the reward
          reward = 0;
        // the played messed it up and killed an innocent cowboy
        } else {
          innocentKilled(playerAddress);
        }
    }

    function askSheriff() payable public {
        // Ensure entry ticket is paid
        require(msg.value >= minimumStake);
        // Increase reward by the amount just paid
        reward += msg.value;

        // Oraclize logic
        uint N = 2; // number of random bytes we want the datasource to return
        uint delay = 0; // number of seconds to wait before the execution takes place
        uint callbackGas = 200000; // amount of gas we want Oraclize to set for the callback function
        bytes32 queryId = oraclize_newRandomDSQuery(delay, N, callbackGas); // this function internally generates the correct oraclize_query and returns its queryId

        // Record the query Id for the played, as it will be needed in the callback
        queriesMapping[queryId] = msg.sender;
    }

    function withdraw() public {
        require(pendingWithdrawals[msg.sender] > 0);
        // Remember to zero the pending refund before
        // sending to prevent re-entrancy attacks
        pendingWithdrawals[msg.sender] = 0;
        // We cannot send the exact reward amount because some gas has been
        // consumed autnomously by the contract for the Oraclize callback
        // function. Hence we rather empty the balance of the contract instead
        // of substracting 'reward' from it.
        msg.sender.transfer(this.balance);
    }
}
