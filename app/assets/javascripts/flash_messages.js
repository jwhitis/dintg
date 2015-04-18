$(document).on("ready page:load", function() {

  // Flash messages fade out after 3 seconds
  if ($(".flash-message").length) {
    window.setTimeout(function() {
      $(".flash-message").fadeOut(function() {
        $(this).remove();
      });
    }, 3000);
  }

});