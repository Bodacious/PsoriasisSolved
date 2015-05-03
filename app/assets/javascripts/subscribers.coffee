jQuery ->
  
  $('#new_subscriber')
    .on "ajax:success", ->
      document.getElementById('new_subscriber').reset()
    
    .on "ajax:error", ->
      