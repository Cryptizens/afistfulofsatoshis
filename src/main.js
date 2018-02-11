import Vue from 'vue'
import App from './App.vue'
import VueRouter from 'vue-router'
import Routes from './routes'

Vue.use(VueRouter);
const router = new VueRouter({
  routes: Routes
});

window.Web3 = require('web3');

new Vue({
  el: '#app',
  router,
  render: h => h(App)
})