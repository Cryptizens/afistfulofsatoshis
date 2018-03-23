<template lang="pug">
    .footer-container
      div
        | © 2018 / <a href="https://medium.com/@vanderstraeten.thomas/blockchain-project-5-a-fistful-of-satoshis-2d104b542981" target="_blank"><u>About</u></a> / <a href="https://github.com/Cryptizens" target="_blank"><u>GitHub</u></a> / Brought to you by Thomas Vanderstraeten from <u><a target="_blank" href="https://cryptizens.io">Cryptizens.io</a></u>
</template>

<style lang="scss" scoped>
.footer-container {
  height: 50px;
  border-top: 1px solid grey;
  width: 1000px;
  margin: 0 auto;
  padding: 10px 20px 40px 20px;
  font-size: 14px;
  align-items: center;
}

@media screen and (max-width: 1000px){
  .footer-container {
    width: 100% !important;
  }
}
</style>
