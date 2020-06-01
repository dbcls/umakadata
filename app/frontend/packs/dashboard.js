import 'bootstrap/dist/js/bootstrap'
import 'bootstrap-datepicker/dist/js/bootstrap-datepicker.min'
import Chart from 'chart.js';

import '../stylesheets/dashboard'

$(function () {
  let cal = $('#calendar');
  let currentDate = cal.val();

  cal.datepicker({
    autoclose: true,
    startDate: cal.data('start-date'),
    endDate: cal.data('end-date'),
    format: 'yyyy-mm-dd',
    todayHighlight: true
  });

  let drawScores = function (date) {
    $.ajax({
      type: 'GET',
      dataType: 'json',
      contentType: 'application/json; charset=UTF-8',
      url: Routes.endpoint_index_path({date: date}),
      timeout: 10000 // 10 sec
    }).done(function (json, textStatus, jqXHR) {
      drawBars(json.data);
      drawTable(json.data, json.date.current);
      currentDate = date;
    }).fail(function (jqXHR, textStatus, errorThrown) {
      window.alert(`${textStatus}: ${jqXHR.status} ${errorThrown}`);
      cal.val(currentDate);
    });
  };

  let barChart = new Chart($('#score-bar'), {
    type: 'bar',
    data: {
      labels: ['Rank A', 'Rank B', 'Rank C', 'Rank D', 'Rank E'],
      datasets: [
        {
          data: [],
          backgroundColor: ['#FF3D7F', '#3FB8AF', '#7FC7AF', '#FF9E9D', '#DAD8A7']
        }
      ],
      options: {}
    },
    options: {
      animation: {
        duration: 1000,
        easing: 'easeOutQuart',
      },
      legend: {
        display: false
      },
      scales: {
        yAxes: [{
          gridLines: {
            display: false
          },
          ticks: {
            min: 0
          }
        }]
      }
    }
  });

  let drawBars = function (json) {
    let data = json.reduce(function (memo, x) {
      memo[x.rank] += 1;

      return memo;
    }, {A: 0, B: 0, C: 0, D: 0, E: 0});

    barChart.data.datasets[0].data = Object.values(data);
    barChart.update();
  };

  let score_desc = function (a, b) {
    if (a.score > b.score) return -1;
    if (a.score < b.score) return 1;
    return 0;
  };

  let drawTable = function (json, date) {
    let table = $('tbody#score-table');

    table.fadeOut(500);

    let html = '';
    json.sort(score_desc).slice(0, 5).forEach(function (x, i) {
      html += '<tr>';
      html += `<td>${x.score}</td>`;
      html += `<td><a href="${Routes.endpoint_path({id: x.id}, {date: date})}">${x.name}</a></td>`;
      html += `<td><a href="${x.endpoint_url}" target="_blank">${x.endpoint_url}</a></td>`;
      html += '</tr>';
    });

    table.html(html);
    table.fadeIn(500);
  };

  $('#update-date').on('click', function () {
    drawScores(cal.val());
  });

  $('#scores').carousel({
    interval: 10000
  });

  drawScores(currentDate);
});
