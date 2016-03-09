$(function() {
  $("#result").hide();

  $("#search_button").on("click", function() {
    var name = $("#name").val();
    var score = $("#score").val();
    var url = "/api/endpoints/search/?name=" + name + "&score=" + score;
    $.getJSON(url, function(data) {
      $("#result").show();
      $("#result_body").empty();
      for (var i = 0; i < data.length; i++) {
        var endpoint = data[i];
        var row = $("<tr>");
        row.append($("<td>").append($("<a>").attr("href", "/endpoints/" + endpoint.id).text(endpoint.name)));
        row.append($("<td>").append($("<a>").attr("href", endpoint.url).text(endpoint.url)));
        row.append($("<td>").text(endpoint.evaluation.score));
        $("#result_body").append(row);
      }
    });
  });
});
