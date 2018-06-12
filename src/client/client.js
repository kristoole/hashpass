import axios from 'axios'

export default (function(){
  return{
    // Start/Stop
    start: function() { return axios.get('/api/start') },
    stop: function(id) { return axios.get('/api/stop/' + id) },

    // Pending
    get_pending:  function() { return axios.get('/api/pending') },
    create_pending: function(name, dictionary, dictionary2, rules,
        mask, hash, hashmode, hashstring) {
      return axios.post('/api/pending', {
        name: name,
        dictionary: dictionary,
        dictionary2: dictionary2,
        rules: rules,
        mask: mask,
        hash: hash,
        hashmode: hashmode,
        hashstring: hashstring
        })
    },
    clear_pending: function() { return axios.delete('api/pending') },
    upload_hash: function() { return axios.post('api/upload') },

    // Running
    get_running:  function() { return axios.get('/api/running') },
    clear_active: function() { return axios.delete('/api/running/clear') },
    promote_next: function() { return axios.get('/api/running/promote') },
    pid_active:   function(id) { return axios.get('/api/running/pid/' + id) },
    clear_running: function() { return axios.delete('api/running') },

    // Cracked
    get_cracked:  function() { return axios.get('api/cracked') },
    insert_cracked: function() { return axios.get('api/cracked/insert') },
    clear_cracked: function() { return axios.delete('api/cracked') },

    // Status
    get_progress: function() { return axios.get('/api/status') },

    // Authorization
    login: function(handle, password) {
      return axios.post('/login', {
        handle: handle,
        password: password
      })
    }
  };
})();
