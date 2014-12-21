$(document).on("ready page:load", function() {

  // Set wrapper height to cover viewport
  var page_height = $(window).outerHeight();
  $("#wrapper").css("min-height", page_height);

  // Set background color of calendar days by event density
  $("#calendar .day").not(".disabled").each(function() {
    var background = dayBackground($(this), "53%");
    $(this).css("background-color", background);
  });

  // Clicking calendar day darkens background color
  $("#calendar .day").not(".disabled").mousedown(function(event) {
    var background = dayBackground($(this), "48%");
    $(this).css("background-color", background);
  }).mouseup(function() {
    var background = dayBackground($(this), "53%");
    $(this).css("background-color", background);
  });

  function dayBackground(element, lightness) {
    var hue = 33;
    var density = +element.data("density");
    hue = Math.round(hue - (hue * density));
    return "hsla(" + hue + ", 100%, " + lightness + ", .85)";
  }

});