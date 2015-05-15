$(document).on("ready page:load", function() {

  // Set background color of calendar days by event density
  $("#calendar td").not(".disabled").each(function() {
    var background = dayBackground($(this), "53%");
    $(this).css("background-color", background);
  });

  // Clicking calendar day triggers animation
  $("#calendar td").not(".disabled").mousedown(function(event) {
    var background = dayBackground($(this), "48%");
    $(this).css("background-color", background);
  }).mouseup(function() {
    var background = dayBackground($(this), "53%");
    $(this).css("background-color", background);

    // Render event list
    var event_list = $(this).data("event-list");
    if (event_list) {
      $("#events").html(event_list);
    } else {
      $("#events").html("<p class='no-events'>You don't have any events scheduled.</p>");
    }

    // Set "Add Event" button path
    var path = $(this).data("path");
    $("#add-event").attr("href", path);

    // Set event list title
    var title = $(this).data("title");
    $("#events-title").text(title);

    $("#calendar .flipper").addClass("flip");
  });

  // Clicking exit button triggers reverse animation
  $("#calendar .exit").click(function() {
    $("#calendar .flipper").removeClass("flip");
  });

  // Loading icon appears on calendar reload
  $("#calendar").find(".previous, .next, .disabled a").click(function() {
    $("#calendar .loading").show();
  });

});

function dayBackground(element, lightness) {
  var hue = 33;
  var density = +element.data("density");
  hue = Math.round(hue - (hue * density));
  return "hsla(" + hue + ", 100%, " + lightness + ", .85)";
}