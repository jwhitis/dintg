$(document).on("ready page:load", function() {

  // Set wrapper height to cover viewport
  var page_height = $(window).outerHeight();
  $("div#wrapper").css("min-height", page_height);

  // Animate background color on button hover
  $("div#sign-in a").hover(function() {
    $("div#overlay").animate({ "opacity" : ".5" }, 200);
  }, function() {
    $("div#overlay").animate({ "opacity" : "1" }, 200); 
  });

});