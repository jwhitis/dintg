$(document).on("ready page:load", function() {

  // Set wrapper height to cover viewport
  var page_height = $(window).outerHeight();
  $("#wrapper").css("min-height", page_height);

  // Flash messages fade out after 3 seconds
  if ($(".flash-message").length) {
    window.setTimeout(function() {
      $(".flash-message").fadeOut(function() {
        $(this).remove();
      });
    }, 3000);
  }

  // Clicking item in gig list flips item
  $(".gig-list li").click(function() {
    $(this).find(".flipper").toggleClass("flip");
  });

});