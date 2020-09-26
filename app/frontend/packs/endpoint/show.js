import 'bootstrap/js/dist/modal';
import 'bootstrap-datepicker/dist/js/bootstrap-datepicker.min';
import Chart from 'chart.js';
import Routes from '../../javascripts/js-routes.js.erb';

import '../../stylesheets/endpoint';

$(function () {
  let $calendar = $('#calendar');

  $calendar.datepicker({
    autoclose: true,
    startDate: $calendar.data('start-date'),
    endDate: $calendar.data('end-date'),
    format: 'yyyy-mm-dd',
    todayHighlight: true
  });

  let currentDate = $calendar.val();

  let $progressDialog = $('#progress-dialog');
  let $scores = $('#scores');
  let $histories = $('#histories');
  let $updateDate = $('#update-date');

  let chartScores = function (data) {
    if (!data.scores) {
      return;
    }

    let labels = Object.keys(data.scores);
    let config = {
      type: 'radar',
      data: {
        labels: labels,
        datasets: [
          {
            label: 'Target',
            backgroundColor: 'rgba(151,187,205,0.2)',
            borderColor: 'rgba(151,187,205,1)',
            pointBorderColor: 'rgba(151,187,205,1)',
            pointBackgroundColor: '#fff',
            data: labels.map(function (x) {
              return data.scores[x];
            })
          },
          {
            label: 'Average',
            backgroundColor: 'rgba(220,220,220,0.5)',
            borderColor: 'rgba(220,220,220,1)',
            pointBorderColor: 'rgba(220,220,220,1)',
            pointBackgroundColor: '#fff',
            data: labels.map(function (x) {
              return data.average[x];
            })
          }
        ]
      },
      options: {
        maintainAspectRatio: false,
      }
    };

    return new Chart(document.getElementById('scores').getContext('2d'), config);
  };

  let chartHistories = function (json) {
    if (!json.labels || !json.datasets) {
      return;
    }

    let data = {
      labels: json.labels,
      datasets: json.datasets
    };

    data.datasets.forEach(function (x) {
      x['lineTension'] = 0;
      x['pointBackgroundColor'] = 'rgba(255, 255, 255, 1)';
      x['fill'] = false;

      switch (x.label) {
      case 'availability':
        x['backgroundColor'] = 'rgba(220, 220, 220, 0.2)';
        x['borderColor'] = x['pointBorderColor'] = 'rgba(220, 220, 220, 1)';
        break;
      case 'freshness':
        x['backgroundColor'] = 'rgba(54, 162, 235, 0.2)';
        x['borderColor'] = x['pointBorderColor'] = 'rgba(54, 162, 235, 1)';
        break;
      case 'operation':
        x['backgroundColor'] = 'rgba(255, 99, 132, 0.2)';
        x['borderColor'] = x['pointBorderColor'] = 'rgba(255, 99, 132, 1)';
        break;
      case 'usefulness':
        x['backgroundColor'] = 'rgba(255, 206, 86, 0.2)';
        x['borderColor'] = x['pointBorderColor'] = 'rgba(255, 206, 86, 1)';
        break;
      case 'validity':
        x['backgroundColor'] = 'rgba(75, 192, 192, 0.2)';
        x['borderColor'] = x['pointBorderColor'] = 'rgba(75, 192, 192, 1)';
        break;
      case 'performance':
        x['backgroundColor'] = 'rgba(21, 7, 119, 0.2)';
        x['borderColor'] = x['pointBorderColor'] = 'rgba(21, 7, 119, 1)';
        break;
      case 'rank':
        x['backgroundColor'] = 'rgba(151, 187, 205, 0.2)';
        x['borderColor'] = x['pointBorderColor'] = 'rgba(151, 187, 205, 1)';
        break;
      default:
        break;
      }
    });

    let config = {
      type: 'line',
      data: data,
      options: {
        maintainAspectRatio: false,
        scales: {
          xAxes: [{
            type: 'time',
            time: {
              parser: 'YYYY-MM-DD',
              unit: 'day',
              tooltipFormat: 'll'
            },
            scaleLabel: {
              display: true,
              labelString: 'Date'
            }
          }],
          yAxes: [{
            ticks: {
              max: 100,
              min: 0
            }
          }]
        }
      }
    };

    return new Chart(document.getElementById('histories').getContext('2d'), config);
  };

  let loadData = function () {
    $.when(
      $.ajax({
        type: 'GET',
        dataType: 'json',
        contentType: 'application/json; charset=UTF-8',
        url: Routes.endpoint_scores_path({id: $scores.data('endpoint')}, {date: currentDate}),
        timeout: 60000 // 60 sec
      }),
      $.ajax({
        type: 'GET',
        dataType: 'json',
        contentType: 'application/json; charset=UTF-8',
        url: Routes.endpoint_histories_path({id: $histories.data('endpoint')}, {date: currentDate}),
        timeout: 60000 // 60 sec
      })
    ).done(function (first, second) {
      window.chartScores = chartScores(first[0]);
      window.chartHistories = chartHistories(second[0]);

      $progressDialog.modal('hide');
    }).fail(function (jqXHR, textStatus, errorThrown) {
      $progressDialog.modal('hide');

      window.alert(`${textStatus}: ${jqXHR.status} ${errorThrown}`);
    });
  };

  $progressDialog.on('shown.bs.modal', function () {
    setTimeout(function () {
      loadData();
    }, 100);
  });

  $updateDate.on('click', function () {
    location.href = Routes.endpoint_path($scores.data('endpoint'), {date: $calendar.val()});
  });

  $progressDialog.modal('show');
});
