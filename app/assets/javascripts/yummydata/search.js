$(function() {
  $("#result").hide();

  $("#search_button").on("click", function() {
    var name = $("#name").val();
    var score = $("#score").val();
    var url = "/api/endpoints/search/?name=" + name + "&score=" + score;
    $.getJSON(url, function(data) {
      $("#result").show();
      for (var i = 0; i < data.length; i++) {
        var row = $("<tr>");
        row.append($("<td>").text(data[i].name));
        row.append($("<td>").text(data[i].url));
        row.append($("<td>").text(data[i].score));
        $("#result_body").append(row);
        console.log(row);
      }
    });
  });
});
