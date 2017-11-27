$(document).ready(function() {
  $("form#search").validate({
    rules: {
      prefix_filter_uri: {
        url: true
      }
    },
    messages: {
      prefix_filter_uri: {
        url: "Please enter a valid URI."
      }
    },
    errorClass: "control-label",
    highlight: function(element, errorClass) {
      $(element).parent().addClass('has-error');
    },
    unhighlight: function(element, errorClass) {
      $(element).parent().removeClass('has-error');
    }
  });
});

$(function() {
  $("#result").hide();

  $("#search").keypress(function(e){
    if (e.which == 13) {
      $("#search_button").click();
    }
  });

  $("#search_button").on("click", function() {
    if(!$("form#search").valid()){
      $('#searching').modal('hide');
      return false;
    }
    $('#collapse').collapse('hide');
    var values = getInputValues();
    var params = createParams(values);
    var url = "/api/endpoints/search/?" + params;
    $.getJSON(url, function(data) {
      $("#result").show();
      $("#result_body").empty();
      for (var i = 0; i < data.length; i++) {
        var endpoint = data[i];
        var row = $("<tr>");
        row.append($("<td>").append($("<a>").attr("href", "/endpoints/" + endpoint.id + '/' + endpoint.evaluation.id).text(endpoint.name)));
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
    else if ($(this).attr('type') == 'checkbox' || $(this).attr('type') == 'radio'){
      if ($(this).is(':checked')){
        params[name] = $(this).val();
      }
    }
  });
  return splitFragmentIdentifier(params);
}

function splitFragmentIdentifier(params) {
  var domainUri = params['prefix_filter_uri'];
  if (domainUri != "") {
    var splited = domainUri.split("#");
    if(splited[1] != undefined) {
      params['prefix_filter_uri'] = splited[0];
      params['prefix_filter_uri_fragment'] = splited[1];
    }
  }
  return params;
}

function createParams(values) {
  var list = new Array();
  for (key in values) {
    list.push(key + "=" + values[key]);
  }

  return list.join("&");
}
