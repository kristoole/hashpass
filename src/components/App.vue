<template>
  <div id='app' class="flex1">
    <div class="navbar">
      <h1><span class="oi mr2" data-glyph="lock-unlocked" title="icon name" aria-hidden="true"></span>Hashpass</h1>
      <ul>
        <a href="#" @click="start"><li>Start</li></a>
        <a href="/"><li>Logout</li></a>
        <!-- <a href="#" @click="stop"><li>Stop</li></a> -->
      </ul>
    </div>
    <div class="view-main">
      <router-view></router-view>
    </div>
  </div>
</template>

<script>
  import store from '../store/store'

  export default {
    data() {
      return {
        activeIndex: '1',
        intervalId: 0,
      };
    },
    methods: {
      start: function() {
        if (store.getters.getPending) {
          store.dispatch('promote_next')
          store.dispatch('start')
        }
        else {
          store.dispatch('start')
        }
      },
      stop: function() {
        store.dispatch('stop')
      },
    },
    name: 'app'
  }
</script>
