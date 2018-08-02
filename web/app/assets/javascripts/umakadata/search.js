//= require bootstrap-datepicker.min
//= require jquery.validate

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
    highlight: function (element) {
      $(element).parent().addClass('has-error');
    },
    unhighlight: function (element) {
      $(element).parent().removeClass('has-error');
    }
  });
});

$(function () {
  $("#search").keypress(function (e) {
    if (e.which === 13) {
      $("#search_button").click();
    }
  });

  $("#search_button").on("click", function () {
    if (!$("form#search").valid()) {
      $('#searching').modal('hide');
      return false;
    }
    $('#collapse').collapse('hide');
    var values = getInputValues();
    var params = createParams(values);
    location.href = "/endpoints/search_result?" + params;
  });
});

function getInputValues() {
  var params = {};
  $('form input').each(function () {
    var name = $(this).attr('name');
    if (name === undefined) {
      return true;
    }
    if ($(this).attr('type') === 'text') {
      params[name] = $(this).val();
    }
    else if ($(this).attr('type') === 'checkbox' || $(this).attr('type') === 'radio') {
      if ($(this).is(':checked')) {
        params[name] = $(this).val();
      }
    }
  });
  return splitFragmentIdentifier(params);
}

function splitFragmentIdentifier(params) {
  var domainUri = params['prefix_filter_uri'];
  if (domainUri !== "") {
    var splited = domainUri.split("#");
    if (splited[1] !== undefined) {
      params['prefix_filter_uri'] = splited[0];
      params['prefix_filter_uri_fragment'] = splited[1];
    }
  }
  return params;
}

function createParams(values) {
  var list = [];
  for (var key in values) {
    list.push(key + "=" + values[key]);
  }

  return list.join("&");
}
