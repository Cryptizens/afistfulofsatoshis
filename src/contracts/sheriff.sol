pragma solidity ^0.4.19;

/*
   Sheriff contract for A fistful of Satoshis Western shooter
*/

import "github.com/oraclize/ethereum-api/oraclizeAPI.sol";

contract Sheriff is usingOraclize {

    event enteredCallback(bytes32 queryId);

    event newRandomNumber_bytes(bytes randomBytes);
    event newRandomNumber_uint(uint randomNumber);

    event outlawKilled(address playerAddress);
    event innocentKilled(address playerAddress);
    event rewardPaid(address playerAddress, uint paidOutValue);

    // The vault of money that is used to pay winners, starts at 0
    uint public moneyInVault = 0;
    // The amount to pay to the Sheriff to play
    uint public entryTicket = 0.25 ether;
    // The maximum payout per win (so that the Sheriff can keep a bit of money
    // to attract other players)
    uint public maximumPayout = 1 ether;
    // Record the queries made by each player, so that we can link a call
    // to the Oraclize fallback function to the initial player ticket.
    mapping (bytes32 => address) queriesMapping;
    // Withdrawal logic (outstanding amount for each player)
    mapping (address => uint) pendingWithdrawals;

    function Sheriff() {
      // Constructor function, not used for anything specific yet
    }

    // Fallback function to reload the overall reward after it's been emptied by
    // a player that won the game
    function () payable {
        moneyInVault += msg.value;
    }

    // Helper function to compute the actual payout of a winning player, so that
    // it can never be higher than the maximum amount defined. This prevents
    // too quick depletion of the money in the vault.
    function _payoutAmount() private returns (uint){
      if (moneyInVault > maximumPayout) {
        return maximumPayout;
      } else {
        return moneyInVault;
        // An improvement here would be to broadcast a 'emptyVaultWarning' event
      }
    }

    // The callback function is called by Oraclize when the result is ready
    function __callback(bytes32 _queryId, string _result) public {
        // Only Oraclize can call this function
        require (msg.sender == oraclize_cbAddress());

        enteredCallback(_queryId);

        // The resulting random bytes returned by Oraclize
        newRandomNumber_bytes(bytes(_result));

        // Let's convert the random bytes to uint, then perform a modulo 4 so
        // that we get as a result one of the following: 0, 1, 2, 3
        uint randomNumber = uint(keccak256(_result)) % 4;

        newRandomNumber_uint(randomNumber);

        address playerAddress = queriesMapping[_queryId];

        // The player is lucky and has killed the outlaw ! 1/4 chances of success
        if (randomNumber == 0) {
          // Broadcast the event
          outlawKilled(playerAddress);
          // Compute the player reward
          uint payout = _payoutAmount();
          // Recognize the full reward for the lucky player, so she can then
          // proceed to withdrawal of the funds.
          pendingWithdrawals[playerAddress] += payout;
          // Update the vault balance
          moneyInVault = moneyInVault - payout;

        // The played messed it up and killed an innocent cowboy
        } else {
          innocentKilled(playerAddress);
          // Nothing more happens here, the money is lost and goes in the vault
        }
    }

    function askSheriff() payable public {
        // Ensure entry ticket is paid
        require(msg.value >= entryTicket);
        // The money goes in the vault
        moneyInVault += msg.value;

        // Oraclize logic
        uint N = 10; // number of random bytes we want the datasource to return
        uint delay = 0; // number of seconds to wait before the execution takes place
        uint callbackGas = 200000; // amount of gas we want Oraclize to set for the callback function
        // This function internally generates the correct oraclize_query and returns its queryId
        bytes32 queryId = oraclize_newRandomDSQuery(delay, N, callbackGas);

        // Record the query Id for the played, as it will be needed in the callback
        // so that we can retrieve the player and update her winner/loser status.
        queriesMapping[queryId] = msg.sender;
    }

    function withdraw() public {
        uint pendingValue = pendingWithdrawals[msg.sender];
        uint paidOutValue;

        require(pendingValue > 0);

        // Remember to zero the pending refund before
        // sending to prevent re-entrancy attacks.
        // Note that the vault balance has been updated when the winning status
        // of the player was recognized earlier. This way we avoid double with-
        // drawals attempts that would have tried to abuse a desynchronization
        // between this.balance and moneyInVault.
        pendingWithdrawals[msg.sender] = 0;

        // Sometimes because of gas consumption we cannot send the full
        // pendingValue as balance is lower (e.g., Oraclize depletes balance).
        // So we've got to cap the paid out value at balance.
        if (pendingValue > this.balance){
          paidOutValue = this.balance;
        } else {
          paidOutValue = pendingValue;
        }

        msg.sender.transfer(paidOutValue);

        rewardPaid(msg.sender, paidOutValue);
    }
}
