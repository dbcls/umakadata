$(function() {
  $("#result").hide();

  $("#search_button").on("click", function() {
    var values = getInputValues();
    var params = createParams(values);
    var url = "/api/endpoints/search/?" + params;
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
      $('#searching').modal('hide');
    });
  });
});

function getInputValues(){
  var params = new Object();
  $('form input').each(function(){
    var name = $(this).attr('name')
    if (name == undefined){
      return true;
    }
    if ($(this).attr('type') == 'text'){
      params[name] = $(this).val();
    }
    else if ($(this).attr('type') == 'checkbox'){
      if ($(this).is(':checked')){
        params[name] = $(this).val();
      }
    }
  });
  return params;
}

function createParams(values) {
  var list = new Array();
  for (key in values) {
    list.push(key + "=" + values[key]);
  }

  return list.join("&");
}
