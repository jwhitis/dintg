$(document).on("ready page:load", function() {

  // Clicking bars icon toggles navbar
  $(".nav-toggle").click(function() {
    if ($("nav").is(":hidden")) {
      $("nav").slideDown(600, "easeOutBounce");
    } else {
      $("nav").slideUp(600, "easeOutQuint");
    }
  });

  // Clicking item in event list flips item
  $(".event-list .flipper").click(function(event) {
    if (event.target.tagName != "A") {
      if ($(this).hasClass("flip")) {
        $(this).removeClass("flip");
      } else {
        $(".event-list .flip").removeClass("flip");
        $(this).addClass("flip");
      }
    }
  });

});