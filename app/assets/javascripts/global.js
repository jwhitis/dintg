$(document).on("ready page:load", function() {

  // Set wrapper height to cover viewport
  var page_height = $(window).outerHeight();
  $("#wrapper").css("min-height", page_height);

  // Set background color of calendar days by event density
  $("#calendar .front").not(".disabled").each(function() {
    var background = dayBackground($(this), "53%");
    $(this).css("background-color", background);
  });

  // Clicking front of calendar day triggers forward animation
  $("#calendar .front").not(".disabled").mousedown(function(event) {
    var background = dayBackground($(this), "48%");
    $(this).css("background-color", background);
  }).mouseup(function() {
    var background = dayBackground($(this), "53%");
    $(this).css("background-color", background);
    $(this).parent(".flipper").addClass("flip");
  });

  // Clicking back of calendar day triggers reverse animation
  $("#calendar .back").not(".disabled").click(function() {
    $(this).parent(".flipper").removeClass("flip");
  });

  function dayBackground(element, lightness) {
    var hue = 33;
    var density = +element.data("density");
    hue = Math.round(hue - (hue * density));
    return "hsla(" + hue + ", 100%, " + lightness + ", .85)";
  }

});