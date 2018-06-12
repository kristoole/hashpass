//
// Libraries
//
import Vue from 'vue'
import Vuex from 'vuex'
import Highcharts from 'highcharts';
import VueHighcharts from 'vue-highcharts';
import client from './client/client.js'
import store from './store/store.js'
import VueTyperPlugin from 'vue-typer'
Vue.use(VueTyperPlugin)
Vue.use(Vuex)
Vue.use(VueHighcharts);


//
// Styles
//
import './styles/custom.scss';

//
// Vue Settings
//
Vue.config.debug         = process.env.NODE_ENV == 'development'
Vue.config.devtools      = process.env.NODE_ENV == 'development'
Vue.config.productionTip = process.env.NODE_ENV == 'development'
Vue.config.silent        = process.env.NODE_ENV != 'development'

//
// Vue Router
//
import router from './routes/router'
import {sync} from 'vuex-router-sync'
sync(store, router);

//
// Vue App
//
import App from './components/App.vue'
import Login from './components/Login.vue'

document.vueApp = new Vue({
  el: '#mainapp',
  router,
  store,
  render: function(h){ return h(App);}
});

document.loginApp = new Vue({
  el: '#loginapp',
  render: function(h){ return h(Login);}
});
