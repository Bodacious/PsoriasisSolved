jQuery(function() {
  $('#new_subscriber').on("ajax:success", function() {
    document.getElementById('new_subscriber').reset();
  }).on("ajax:error", function() {});
});