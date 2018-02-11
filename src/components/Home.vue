<template lang="pug">
    div
      div.header
        h1 A fistful of Satoshis
        h2 A Blockchain-based Western shooting game
      #startScreen.splash.text-splash(v-if="!gameOngoing")
        h2 Welcome to the game!
        button(id="startButton" @click="startGame") Start the game!
      #shootingRange.splash(@click="shoot" v-if="gameOngoing")
        img(id="cowboy" src="../assets/cowboy.png" @click="hit")
        #badges
          img.badge(v-for="s in score" src="../assets/badge.png")
      #waitScreen.splash.text-splash(v-if="gameFinished")
</template>

<script>
import { abi } from '../contracts/abi'
import { address } from '../contracts/address'

export default {
  components: {
    // 'app-memory': Memory
  },
  data() {
    return {
      score: -1
    }
  },
  computed: {
    gameOngoing() {
      return this.score >= 0 && this.score < 5;
    },
    gameFinished() {
      return this.score >= 5;
    }
  },
  methods: {
    startGame() {
      this.score += 1;
    },
    // Called at page load, to retrieve all existing memories from the Blockchain.
    // We use an infura node instead of an in-browser wallet, so that all users
    // can see the full list of memories, even if they're not tech-savvy.
    populateMemories() {
      // Retrieve the contract to interact with it
      var remoteWeb3 = new Web3(
          new Web3.providers.HttpProvider('https://rinkeby.infura.io/')
      );
      const Memorial = new remoteWeb3.eth.Contract(abi, address);

      self = this;

      // Get the current number of memories so we know till where we can iterate
      Memorial.methods.getMemoriesCount().call(function (error, result) {
        const MemoriesCount = result;
        const MaxIndex = Math.min(self.maxOnDisplay, MemoriesCount);

        var selff = self;
        // Iterate on all the memories and insert them in the Vue instance data
        for (var i = 0; i < MaxIndex; i++) {
          Memorial.methods.memories(i).call(function (error, result) {
            selff.insertMemory(result);
          });
        };
        console.log('Done loading all memories');
      });
    },
    shoot: function(evt){
      var audio = new Audio('./src/assets/bullet.mp3');
      audio.play();

      var canvas = document.getElementById('shootingRange');
      var rect = canvas.getBoundingClientRect();

      var x = Math.floor( ( evt.clientX - rect.left ) / ( rect.right - rect.left ) * canvas.offsetWidth );
      var y = Math.floor( ( evt.clientY - rect.top ) / ( rect.bottom - rect.top ) * canvas.offsetHeight );

      var img = document.createElement("img");
      img.src = './src/assets/hole.png';
      img.style.height = "70px";
      img.style.position = "absolute";
      img.style.top = y - 18 + "px";
      img.style.left = x - 18 + "px";

      img.className += " hole";

      document.getElementById('shootingRange').appendChild(img);
    },
    hit: function(evt) {
      console.log("hit!")
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
.title-links {
  font-size: 14px;
  text-align: center;
  margin-bottom: 60px;
}

// .header {
//   margin-bottom: 100px;
// }

p {
  text-align: center;
  font-size: 12px;
}

.splash {
  width: 1000px;
  height: 500px;
  border-radius: 5px;
  background-color: rgba(255,255,255, 0.7);
  color: #2c3e50;
}

.text-splash {
  display: flex;
  justify-content: center;
  align-items: center;
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
