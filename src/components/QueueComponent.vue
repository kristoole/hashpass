<template>
  <div style="text-align:center">
    <div class="view-queue">
      <h2>Queue</h2>
      <div>
        <button class="btn btn--small" v-on:click="clear">
          <span class="oi mr2" data-glyph="ban" title="icon name" aria-hidden="true"></span>
          Clear
        </button>
        <button class="btn btn--primary" @click="showModal">
          <span class="oi mr2" data-glyph="plus" title="icon name" aria-hidden="true"></span>
          Add
        </button>
        <button class="btn btn--small" v-on:click="promote_next">
          <span class="oi mr2" data-glyph="arrow-circle-top" title="icon name" aria-hidden="true"></span>
          Next
        </button>
      </div>
      <!-- <transition-group name="card" class="card-transition"> -->
        <div class="card" v-for="queue in getPending" v-bind:key="queue">
          <div class="card__header">
            <span class="oi mr2 fr" data-glyph="wifi" title="icon name" aria-hidden="true"></span>
            {{queue.hash}} {{queue.hashstring}}
          </div>
          <div class="card__body">
            <p v-if="queue.hashmode">Type: <span>{{queue.hashmode}}</span></p>
            <p v-if="queue.name">Type: <span>{{queue.name}}</span></p>
            <p v-if="queue.dictionary">Dictionary: <span>{{queue.dictionary}}</span></p>
            <p v-if="queue.dictionary2">Dictionary 2: <span>{{queue.dictionary2}}</span></p>
            <p v-if="queue.rules">Rules <span>{{queue.rules}}</span></p>
            <p v-if="queue.mask">Mask: <span>{{queue.mask}}</span></p>
          </div>
        </div>
      <!-- </transition-group> -->
    </div>
    <modal v-if="modalVisible" @close="hideModal">
      <h3 slot="header">
        Crack new hash
        <button class="btn btn--small modal-default-button mt0" @click="hideModal">
          Close
        </button>
      </h3>
      <job-form slot="body"></job-form>
    </modal>
  </div>
</template>


<script>
  import store from '../store/store'
  import JobForm from '../components/JobForm.vue'
  import Modal from '../components/ModalComponent.vue'

  export default {
    components: {JobForm: JobForm, Modal: Modal},

    computed: {
      getPending: function() { return store.getters.getPending; },
      modalVisible: function() { return store.getters.getShowModal; }
    },
    methods: {
      clear: function() {
        store.dispatch('clear_running')
      },
      showModal: function() { store.dispatch('show_modal') },
      hideModal: function() { store.dispatch('hide_modal') },
      promote_next: function() {
        store.dispatch('promote_next')
          .then(function() {
            store.dispatch('get_pending');
            store.dispatch('get_running');
          })
          .catch((error)=>{ console.error('promote_next', error)
        })
      }
    }
  }
</script>
