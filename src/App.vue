<template lang="pug">
  div(id="app")
    .wrapper
      .container
        Home
      Footer
</template>

<script>
import Home from './components/Home.vue'
import Footer from './components/Footer.vue'

export default {
  name: 'app',
  components: {
    Home,
    Footer
  }
}
</script>
<style lang="scss">
#app {
  font-family: 'Lato', Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  color: white;
  background-image: url('./assets/chair.jpg');
  background-repeat: no-repeat;
  background-attachment: fixed;
  background-size: cover;
}
body {
  margin: 0;
}

h1 {
  margin-top: 5px;
  text-align: center;
  font-family: 'Rye';
  font-size: 70px;
  letter-spacing: 5px;
  margin-bottom: 20px;
}
h2 {
  text-align: center;
  font-size: 20px;
  margin-bottom: 30px;
}

.wrapper {
  min-height: 100vh;
}

.container {
  padding: 30px;
  padding-top: 70px;
  max-width: 1000px;
  height: 100%;
  margin: 0 auto;

  @media screen and (max-width: 1000px){
      margin-left: 20px !important;
      margin-right: 20px !important;
  }
}

@media screen and (max-width:1000px){
  .hide-mobile{
      display:none
  }
}

a {
  text-decoration: none;
  color: inherit;
}

button {
  background-color: #151515;
  font-weight: bold;
  border: none;
  color: white;
  padding: 15px 32px;
  text-align: center;
  text-decoration: none;
  display: inline-block;
  font-size: 16px;
  border-radius: 5px;
  cursor: pointer;
}

@media screen and (max-width: 1000px){
    h1 {
      font-size: 30px;
    }
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
  flex-direction: column;
}
</style>
