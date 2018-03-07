<template lang="pug">
    div
      div.header
        h1 A fistful of Satoshis
        h2 A Blockchain-based Western shooting game

      #startScreen.splash.text-splash(v-if="gameNotStarted")
        h2 Welcome, cowboy.
        p <b>Billy the Kid</b> has been seen at The Old Vitalik's saloon, with his crew of outlaws. Billy is public enemy #1, and there's a <b>reward of up to 1 ETHER</b> if you take him, dead or alive.
        p You will enter a <b>gun duel with Billy</b>. But be careful: you had <b>too much whisky</b>! It would be bad if you killed the wrong cowboy and went to jail, losing all you money...
        p The rule is simple: <b>hit the cowboy 5 times</b>. Then we'll go to the Sheriff that lives on the Ethereum Blockchain, and see whether you deserve the reward or deserve to be jailed!
        br
        button(id="startButton" @click="startGame") Start the game!

      #shootingRange.splash(@click="shoot" v-if="gameOngoing")
        img(id="cowboy" src="../assets/cowboy.png" @click="hit")
        #badges
          img.badge(v-for="s in score" src="../assets/badge.png")

      #gameFinishedScreen.splash.text-splash(v-if="gameFinished")
        h2 You killed that cowboy!
        p Was it Billy the Kid, or just some innocent cowboy?
        p The only way to find it out is to go the <b>Sheriff that lives on the Ethereum Blockchain</b>. That'll cost you <b>0.25 ETH</b> from the Rinkeby Testnet (get <u><a href="https://faucet.rinkeby.io/" target="_blank">some for free here</a></u>).
        p If you killed an innocent, you'll go to jail and lose your money. If you killed Billy, you'll get <b>a reward from the Sheriff</b>!
        p The amount of money in the Sheriff's vault is <b>{{ moneyInVault }} ETH</b>, and the max reward you can get is 1 ETH.
        br
        button(id="startButton" @click="goToSheriff") Go to the Sheriff

      #pendingAnswerScreen.splash.text-splash(v-if="pendingAnswer")
        img(src="https://s3.eu-central-1.amazonaws.com/afistfulofsatoshis.fun/spinner.gif" style="height: 50px")
        h2 The Sheriff is reviewing the corpse!
        p You'll know soon whether you won or lost the game...this usually takes about <b>2-3 minutes</b>. Why? Because your transaction needs to mined and other funky stuff needs to happen <b>asynchronously on the Blockchain</b>.
        p In the meanwhile, why don't you <b><u><a href="https://medium.com/@vanderstraeten.thomas/blockchain-project-5-a-fistful-of-satoshis-2d104b542981" target="_blank">check out the blog</a></u></b> to discover more on the intricacies of gaming on Blockchain?

      #gameOverScreen.splash.text-splash(v-if="gameOver")
        img(src="https://s3.eu-central-1.amazonaws.com/afistfulofsatoshis.fun/jail.png" style="height: 150px")
        h2 GAME OVER
        p Too bad...<b>you killed an innocent</b> and end up in prison, <b>losing all your money</b>! Why not play again, if your wallet is not empty ;) ?

      #gameWonScreen.splash.text-splash(v-if="gameWon")
        img(src="https://s3.eu-central-1.amazonaws.com/afistfulofsatoshis.fun/vault.png" style="height: 170px")
        h2 YOU WON!
        p Well done! You killed Billy the Kid. You can know <b>claim your reward</b> and withdraw money from the Sheriff's vault!
        br
        button(id="claimRewardButton" @click="claimReward") Claim your reward!
</template>

<script>
import { abi } from '../contracts/abi'
import { address } from '../contracts/address'

export default {
  data() {
    return {
      score: -1,
      sheriffState: 'pending_request',
      moneyInVault: null
    }
  },
  computed: {
    gameNotStarted() {
      return this.score < 0;
    },
    gameOngoing() {
      return this.score >= 0 && this.score < 5;
    },
    gameFinished() {
      return (this.score >= 5 && this.sheriffState == 'pending_request');
    },
    pendingAnswer() {
      return this.sheriffState == 'pending_answer';
    },
    gameOver() {
      return this.sheriffState == 'game_over';
    },
    gameWon() {
      return this.sheriffState == 'game_won';
    }
  },
  methods: {
    assetPath: function (asset) {
      return require('../assets/' + asset);
    },
    startGame() {
      this.score += 1;
    },
    shoot: function(evt){
      var audio = new Audio('https://s3.eu-central-1.amazonaws.com/afistfulofsatoshis.fun/bullet.mp3');
      audio.play();

      var canvas = document.getElementById('shootingRange');
      var rect = canvas.getBoundingClientRect();

      var x = Math.floor( ( evt.clientX - rect.left ) / ( rect.right - rect.left ) * canvas.offsetWidth );
      var y = Math.floor( ( evt.clientY - rect.top ) / ( rect.bottom - rect.top ) * canvas.offsetHeight );

      var img = document.createElement("img");
      img.src = this.assetPath('hole.png');
      img.style.height = "70px";
      img.style.position = "absolute";
      img.style.top = y - 18 + "px";
      img.style.left = x - 18 + "px";

      img.className += " hole";

      document.getElementById('shootingRange').appendChild(img);
    },
    hit: function(evt) {
      this.score+= 1;
      if (this.gameFinished){
        setTimeout(this.cleanup(), 500);
        this.getMoneyInVaultAmount();
      }
    },
    cleanup() {
      var images = document.getElementsByClassName('hole');
      for(var i = 0; i < images.length; i++) {
          images[i].style.visibility = 'hidden';
      }
    },
    getMoneyInVaultAmount() {
      self = this;
      web3.eth.getBalance(address, function(e,r){
        self.moneyInVault = r.c[0]/10000;
      });
    },
    claimReward() {
      this.contract().withdraw(function(e,r){
        console.log(e);
        console.log(r);
      });
    },
    goToSheriff() {
      self = this
      this.contract().askSheriff({from: this.account(), value: this.stake()}, function(error, result){
        console.log(error);
        console.log(result);
        self.evolveSheriffState('pending_answer');
      });
    },
    // Helper function to get the contract js interface, using an in-browser
    // wallet such as MetaMask - we cannot use infura here since we're making
    // a real transaction rather than a call and hence need the user to approve
    // the Tx before it is sent to the blockchain
    contract() {
      return web3.eth.contract(abi).at(address);
    },
    account() {
      return web3.eth.accounts[0];
    },
    stake() {
      return web3.toWei('0.25', 'ether');
    },
    evolveSheriffState: function(state){
      this.sheriffState = state;
    }
  },
  mounted() {
    self = this;

    $(document).bind('DOMNodeInserted', function(event) {
      if (event.target.id == "cowboy") {
        moveCowBoy();
      }
    });

    function makeNewPosition(){
        var w = $('#shootingRange').width() - 50;
        var nw = Math.floor(Math.random() * w);

        return nw;
    }

    function moveCowBoy(){
        var newq = makeNewPosition();
        var oldq = $('#cowboy').offset().left;
        var speed = calcSpeed(oldq, newq);

        $('#cowboy').animate({ bottom: 10, left: newq }, speed, function(){
          moveCowBoy();
        });
    };

    function calcSpeed(prev, next) {
        var x = Math.abs(prev - next);
        var speedModifier = 0.2;
        var speed = Math.ceil(x/speedModifier);

        return speed;
    };

    this.contract().enteredCallback(function(error, result) {
      console.log('enteredCallback');
      if (error) return;
      console.log(result.args);
    });

    this.contract().newRandomNumber_bytes(function(error, result) {
      console.log('newRandomNumber_bytes');
      if (error) return;
      console.log(result.args);
    });

    this.contract().newRandomNumber_uint(function(error, result) {
      console.log('newRandomNumber_uint');
      if (error) return;
      console.log(result.args);
    });

    this.contract().outlawKilled(function(error, result) {
      console.log('outlawKilled');
      console.log(result.args);
      if (result.args.playerAddress = self.account()){
        self.evolveSheriffState('game_won');
      }
    });

    this.contract().innocentKilled(function(error, result) {
      console.log('innocentKilled');
      console.log(result.args);
      if (result.args.playerAddress = self.account()){
        self.evolveSheriffState('game_over');
      }
    });
  }
}
</script>

<style lang="scss" scoped>
p {
  width: 50%;
  text-align: center;
}

#shootingRange {
  background-image: url('../assets/city.jpg');
  background-repeat: no-repeat;
  background-size: cover;

  cursor: url('../assets/crosshair.png'), pointer;

  user-select: none;
  -moz-user-select: none;
  -khtml-user-select: none;
  -webkit-user-select: none;
  -o-user-select: none;

  position: relative;
}

#waitScreen {

}

#cowboy {
  height: 200px;
  position: absolute;
  bottom: 10px;
  z-index: 100;

  cursor: url('../assets/crosshair.png'), pointer;
}

#badges {
  position: absolute;
  top: 10px;
  left: 10px;
  display: inline;


  .badge{
    height: 30px;
    width: 30px;
    margin: 3px;
    padding: 5px;
    border-radius: 50%;
    background-color: lighten(#9E6D46, 40%);
  }
}
</style>
