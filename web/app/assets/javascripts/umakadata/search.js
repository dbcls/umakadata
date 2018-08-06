//= require bootstrap-datepicker.min
//= require jquery.validate

$(document).ready(function() {
  $("form#search").validate({
    rules: {
      'search_form[prefix_filter_uri]': {
        url: true
      }
    },
    messages: {
      'search_form[prefix_filter_uri]': {
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
    $('#searching').modal('show');
    $('#collapse').collapse('hide');
  });
});
