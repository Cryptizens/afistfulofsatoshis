<template lang="pug">
    div
      div.header
        h1 A fistful of Satoshis
        h2 A Blockchain-based Western shooting game
      #startScreen.splash.text-splash(v-if="gameNotStarted")
        h2 Welcome, cowboy.
        p <b>Billy the Kid</b> has been seen at The Old Vitalik's saloon, with his crew of outlaws. Billy is public enemy #1, and there's a <b>reward of several ETHERs</b> if you take him, dead or alive.
        p You're about to start a <b>gun duel with Billy</b>. But you should better be careful, because you've been drinking too much whisky ! That would be bad if you happened to kill the wrong cowboy and go to jail, losing all you money...
        p The rule of the game is simple: <b>hit the cowboy 5 times</b>. Then we'll go to the Sheriff that lives on the Ethereum Blockchain, and see whether you deserve the reward or deserve to be jailed !
        button(id="startButton" @click="startGame") Start the game!
      #shootingRange.splash(@click="shoot" v-if="gameOngoing")
        img(id="cowboy" src="../assets/cowboy.png" @click="hit")
        #badges
          img.badge(v-for="s in score" src="../assets/badge.png")
      #waitScreen.splash.text-splash(v-if="gameFinished")
        h2 You killed that cowboy!
        p Is it really Billy the Kid that you killed? Or just some innocent cowboy?
        p The only way to find it out is to go the Sheriff that lives on the Ethereum Blockchain. That'll cost you 0.25 ETH from the Rinkeby Testnet (get <u><a href="https://faucet.rinkeby.io/" target="_blank">some for free here</a></u>).
        p If you killed an innocent, you'll go to jail and lose your 0.25 ETH. If you killed Billy, you'll get all the money owned by the Sheriff!
        button(id="startButton" @click="startGame") Go to the Sheriff
</template>

<script>
import { abi } from '../contracts/abi'
import { address } from '../contracts/address'

export default {
  data() {
    return {
      score: -1
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
      return this.score >= 5;
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
      }
    },
    cleanup() {
      var images = document.getElementsByClassName('hole');
      for(var i = 0; i < images.length; i++) {
          images[i].style.visibility = 'hidden';
      }
    }
  },
  mounted() {
    $(document).bind('DOMNodeInserted', function(event) {
      if (event.target.id == "cowboy") {
        animateDiv();
      }
    });

    function makeNewPosition(){
        var w = $('#shootingRange').width() - 50;
        var nw = Math.floor(Math.random() * w);

        return nw;
    }

    function animateDiv(){
        var newq = makeNewPosition();
        var oldq = $('#cowboy').offset().left;
        var speed = calcSpeed(oldq, newq);

        $('#cowboy').animate({ bottom: 10, left: newq }, speed, function(){
          animateDiv();
        });
    };

    function calcSpeed(prev, next) {
        var x = Math.abs(prev - next);
        var speedModifier = 0.2;
        var speed = Math.ceil(x/speedModifier);

        return speed;
    }
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
