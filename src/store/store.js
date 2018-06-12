import Vue from 'vue'
import Vuex from 'vuex'
import client from './../client/client.js'
Vue.use(Vuex);

const state = {
  running: '',
  items: [],
  cracked: [],
  item: {
    name: '',
    dictionary: '',
    dictionary2: '',
    rules: '',
    mask: '',
    hash: '',
    hashmode: '',
    hashstring: '',
    files: []
  },
  progress: '',
  cmd: '',
  pid: '',
  isRunning: false,
  pidActive: '',
  showModal: false,
};

const actions = {
  get_pending(context){
    let _this = this
    client.get_pending()
      .then(function(response){
        _this.commit('load_items', response.data)
      })
      .catch(function(error) {
        console.error('get panding:', error)
      })
  },

  create_pending(context, params) {
    return client.create_pending(params.name, params.dictionary, params.dictionary2,
      params.rules, params.mask, params.hash, params.hashmode, params.hashstring)
  },

  login(context, params) {
    console.log('store loggin', params)
    return client.login(params.handle, params.password)
  },

  promote_next(context) {
    if (context.pid) client.stop(context.pid)
    return client.promote_next()
  },

  start(context) {
    let _this = this
    client.start()
      .then(function(response){
        _this.commit('start', response.data)
      })
      .catch(function(error) {
        console.error('error in start', error)
      })
  },
  stop(context, id) {
    let _this = this
    _this.commit('stop')
    return client.stop(id)
  },

  stopnow(context) {
    let _this = this
    _this.commit('stop')
    return client.stop(context.pid)
  },

  get_progress(context) {
    let _this = this
    client.get_progress()
      .then(function(response){
        _this.commit('get_progress', response.data)
      })
      .catch(function(error) {
        console.error('error in get_progress', error)
      })
  },

  get_running(context) {
    let _this = this
    client.get_running()
      .then(function(response){
        _this.commit('load_running', response.data)
      })
      .catch(function(error) {
        console.error('error in get_running', error)
      })
  },

  clear_running(context) {
    client.clear_running()
    return true
  },

  clear_running(context) {
    let _this = this
    client.clear_pending()
      .then(function(response) {
        _this.commit('clear_pending')
      })
      .catch(function(error) {
        console.log('error in clear_pending', error)
      })
  },

  get_cracked(context) {
    let _this = this
    client.get_cracked()
      .then(function(response){
        _this.commit('load_cracked', response.data)
      })
      .catch(function(error) {
        console.error('error in get_cracked', error)
      })
  },

  insert_cracked(context) {
    let _this = this
    console.log('insert to client..')
    client.insert_cracked()
      .then(function(response) {
        console.log('insert response', response);
        _this.commit('insert_cracked', response.data)
      })
      .catch(function(error) {
        console.log('error in insert_cracked', error)
      })
  },
  clear_cracked(context) {
    let _this = this
    client.clear_cracked()
      .then(function(response) {
        _this.commit('clear_cracked')
      })
      .catch(function(error) {
        console.log('error in clear_cracked', error)
      })
  },
  clear_active(context) {
    let _this = this
    client.clear_active()
      .then(function(response) {
        _this.commit('load_active', response.data)
      })
      .catch(function(error) {
        console.error('error in get_running', error)
      })
  },

  load_pid_active(context, id) {
    let _this = this
    client.pid_active(id)
      .then(function(response) {
        _this.commit('load_pid_active', response.data)
      })
      .catch(function(error) {
        console.error('error in load_pid_active', error)
      })
  },

  show_modal(context) {
    let _this = this
    _this.commit('show_modal')
  },
  hide_modal(context) {
    let _this = this
    _this.commit('hide_modal')
  }
};

const mutations = {
  load_pid_active (context, data) { context.pidActive = data.pid },
  get_progress (context, data){ context.progress = data },
  load_items (context, data){ context.items = data.pending },
  load_running (context, data){ context.running = data.running || ''; },
  load_cracked (context, data){ context.cracked = data.cracked || ''; },
  insert_cracked (context) { console.log('insert', data, context.cracked); context.cracked = data.cracked },
  load_item (context, data){ context.item = data.item },
  clear_items (context){ context.items = [] },
  clear_item(context){ context.item = { title: '' }},
  clear_running(context) { context.running = [] },
  clear_pending(context) { context.items = [] },
  clear_cracked(context) { context.cracked = [] },
  show_modal(context) { context.showModal = true; },
  hide_modal(context) { context.showModal = false; },
  stop(context) { context.isRunning = false; },
  start(context, data){
    context.cmd = data.cmd;
    context.pid = data.pid;
    context.isRunning = true;
  }
};

const getters = {
  getItem (state){ return state.item },
  getItems (state){ return state.items },
  getPending (state){ return state.items },
  getRunning (state) { return state.running },
  getProgress (state) { return state.progress },
  getCmd(state) { return state.cmd },
  getPid(state) { return state.pid },
  getIsRunning(state) { return state.isRunning },
  getCracked(state) { return state.cracked },
  getPidActive(state) { return state.pidActive },
  getShowModal(state) { return state.showModal; }
};

export default new Vuex.Store({
  state: state,
  actions: actions,
  mutations: mutations,
  getters: getters
});

