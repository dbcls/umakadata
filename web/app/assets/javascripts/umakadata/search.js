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
});

// function splitFragmentIdentifier(params) {
//   var domainUri = params['prefix_filter_uri'];
//   if (domainUri !== "") {
//     var splited = domainUri.split("#");
//     if (splited[1] !== undefined) {
//       params['prefix_filter_uri'] = splited[0];
//       params['prefix_filter_uri_fragment'] = splited[1];
//     }
//   }
//   return params;
// }
