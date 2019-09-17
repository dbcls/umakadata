import 'bootstrap/dist/js/bootstrap'
import 'bootstrap-datepicker/dist/js/bootstrap-datepicker.min'

import '../stylesheets/dashboard.scss'

$(function () {
  let cal = $('#calendar');

  cal.datepicker({
    autoclose: true,
    startDate: cal.data('start-date'),
    endDate: new Date(),
    format: 'dd-M-yyyy',
    todayHighlight: true
  });

  let drawScores = function() {
    var input_date = $('#calendar').val();
    var param = (input_date === '') ? '' : '/?date=' + input_date;
    var f = $.getJSON("/endpoints/scores" + param, function (json) {
      showBar("#score", make_score_data(json));
    });

    $.ajax({
      type: 'GET',
      dataType: 'json',
      contentType: 'application/json; charset=UTF-8',
      url: JsRoutes.dashboard_score_path,
      timeout: 10000, // 10 sec
      success: function (data, textStatus, jqXHR) {
        // 成功時
      },
      error: function (jqXHR, textStatus, errorThrown) {
        // 失敗時
      }
    })
  };

  $('#update-date').on("click", function () {
    let input_date = $("#calendar").val();
    let param = (input_date === '') ? '' : '?date=' + input_date;

    location.href = "/" + param
  });

  $('#scores').carousel({
    interval: 10000
  });

  drawScores();
});
