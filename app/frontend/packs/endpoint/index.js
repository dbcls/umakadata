import 'bootstrap-datepicker/dist/js/bootstrap-datepicker.min';
import Chart from 'chart.js';
import Routes from '../../javascripts/js-routes.js.erb';

import '../../stylesheets/endpoint';

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

  const config = {
    rank: {
      type: 'bar',
      data: {},
      options: {
        maintainAspectRatio: false,
        scales: {
          xAxes: [{
            stacked: true
          }],
          yAxes: [{
            stacked: true,
          }]
        },
        legend: {
          reverse: true,
          labels: {
            boxWidth: 20
          }
        }
      }
    },
    score: {
      type: 'line',
      data: {},
      options: {
        maintainAspectRatio: false,
        scales: {
          yAxes: [
            {
              ticks: {
                max: 100,
                min: 0
              }
            }
          ]
        }
      }
    },
    population: {
      type: 'line',
      data: {},
      options: {
        maintainAspectRatio: false,
        scales: {
          yAxes: [
            {
              ticks: {
                max: 100,
                min: 0
              }
            }
          ]
        }
      }
    },
  };

  const CHART_COLORS = {
    red: 'rgb(255, 99, 132)',
    orange: 'rgb(255, 159, 64)',
    yellow: 'rgb(255, 205, 86)',
    green: 'rgb(75, 192, 192)',
    blue: 'rgb(54, 162, 235)',
    purple: 'rgb(153, 102, 255)',
    grey: 'rgb(201, 203, 207)'
  };

  const CHART_COLORS_DARK = {
    red: 'rgb(255, 99, 132, 0.2)',
    orange: 'rgb(255, 159, 64, 0.2)',
    yellow: 'rgb(255, 205, 86, 0.2)',
    green: 'rgb(75, 192, 192, 0.2)',
    blue: 'rgb(54, 162, 235, 0.2)',
    purple: 'rgb(153, 102, 255, 0.2)',
    grey: 'rgb(201, 203, 207, 0.2)'
  };

  const set_color = function (data) {
    data.datasets.forEach(x => {
      switch (x.label) {
      case 'Rank A':
        x.backgroundColor = CHART_COLORS.blue;
        break;
      case 'Rank B':
        x.backgroundColor = CHART_COLORS.green;
        break;
      case 'Rank C':
        x.backgroundColor = CHART_COLORS.yellow;
        break;
      case 'Rank D':
        x.backgroundColor = CHART_COLORS.orange;
        break;
      case 'Rank E':
        x.backgroundColor = CHART_COLORS.red;
        break;
      case 'Average':
      case 'Alive (%)':
        x.backgroundColor = CHART_COLORS_DARK.blue;
        x.borderColor = CHART_COLORS.blue;
        x.pointBorderColor = CHART_COLORS.blue;
        x.pointBackgroundColor = '#fff';
        break;
      case 'Median':
      case 'ServiceDescription (%)':
        x.backgroundColor = CHART_COLORS_DARK.yellow;
        x.borderColor = CHART_COLORS.yellow;
        x.pointBorderColor = CHART_COLORS.yellow;
        x.pointBackgroundColor = '#fff';
        break;
      case 'VoID (%)':
        x.backgroundColor = CHART_COLORS_DARK.red;
        x.borderColor = CHART_COLORS.red;
        x.pointBorderColor = CHART_COLORS.red;
        x.pointBackgroundColor = '#fff';
        break;
      }
    });

    return data;
  };

  const draw_rank = function (date) {
    fetch(Routes.endpoint_statistics_path({date: date}), {
      method: 'GET',
      headers: {
        'Content-Type': 'application/json; charset=UTF-8'
      }
    }).then(response => response.json())
      .then(data => {
        const rank = Object.assign(config.rank, { data: set_color(data.rank) });
        const score = Object.assign(config.score, { data: set_color(data.score) });
        const population = Object.assign(config.population, { data: set_color(data.population) });
        rank.options.scales.yAxes[0].ticks = {
          max: data.options.rank.max,
          min: 0
        };

        new Chart($('#rank'), rank);
        new Chart($('#score'), score);
        new Chart($('#population'), population);
      });
  };

  $('#update-date').on('click', function () {
    location.href = Routes.endpoint_index_path({date: cal.val()});
  });

  draw_rank(currentDate);
});
