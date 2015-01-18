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

  // Clicking bars icon toggles navbar
  $(".nav-toggle").click(function() {
    if ($("nav").is(":hidden")) {
      $("nav").slideDown(600, "easeOutBounce");
    } else {
      $("nav").slideUp(600, "easeOutQuint");
    }
  });

  // Clicking item in gig list flips item
  $(".gig-list li").click(function(event) {
    if (event.target.tagName != "A") {
      $(this).find(".flipper").toggleClass("flip");
    }
  });

});