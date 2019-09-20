import 'bootstrap/dist/js/bootstrap'
import 'bootstrap-datepicker/dist/js/bootstrap-datepicker.min'
import Chart from 'chart.js';

import '../../stylesheets/endpoint/index.scss'

$(function () {
  let cal = $('#calendar');

  cal.datepicker({
    autoclose: true,
    startDate: cal.data('start-date'),
    endDate: cal.data('end-date'),
    format: 'yyyy-mm-dd',
    todayHighlight: true
  });

  const PIE_CHART_OPTIONS = {
    animation: {
      duration: 1000
    }
  };

  const LINE_CHART_OPTIONS = {
    animation: {
      duration: 1000
    },
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
  };

  let canvas = {
    score_rank: new Chart($('#score_rank'), {
      type: 'pie',
      data: {
        labels: ['Rank A', 'Rank B', 'Rank C', 'Rank D', 'Rank E'],
        datasets: [
          {
            data: [0, 0, 0, 0, 0],
            backgroundColor: ['#1D2088', '#00A0E9', '#009944', '#FFF100', '#E60012'],
            hoverBackgroundColor: ['#6356A3', '#00B9EF', '#03EB37', '#FFF462', '#FF5A5E']
          }
        ]
      },
      options: PIE_CHART_OPTIONS
    }),
    alive: new Chart($('#alive'), {
      type: 'pie',
      data: {
        labels: ['Alive', 'Dead'],
        datasets: [
          {
            data: [0, 0],
            backgroundColor: ['#00A0E9', '#E60012'],
            hoverBackgroundColor: ['#00B9EF', '#FF5A5E']
          }
        ]
      },
      options: PIE_CHART_OPTIONS
    }),
    sd: new Chart($('#sd'), {
      type: 'pie',
      data: {
        labels: ['Have', 'Do not have'],
        datasets: [
          {
            data: [0, 0],
            backgroundColor: ['#00A0E9', '#E60012'],
            hoverBackgroundColor: ['#00B9EF', '#FF5A5E']
          }
        ]
      },
      options: PIE_CHART_OPTIONS
    }),
    score_statistics: new Chart($('#score_statistics'), {
      type: 'line',
      data: {
        labels: [],
        datasets: [
          {
            label: ['Average'],
            data: [],
            lineTension: 0,
            backgroundColor: 'rgba(0,160,233,0.2)',
            borderColor: 'rgba(0,160,233,1)',
            pointBorderColor: 'rgba(0,160,233,1)',
            pointBackgroundColor: '#fff'
          },
          {
            label: ['Median'],
            data: [],
            lineTension: 0,
            backgroundColor: 'rgba(255, 99, 132, 0.2)',
            borderColor: 'rgba(255, 99, 132,1)',
            pointBorderColor: 'rgba(255, 99, 132,1)',
            pointBackgroundColor: '#fff'
          }
        ]
      },
      options: LINE_CHART_OPTIONS
    }),
    alive_statistics: new Chart($('#alive_statistics'), {
      type: 'line',
      data: {
        labels: [],
        datasets: [
          {
            label: ['Alive'],
            data: [],
            lineTension: 0,
            backgroundColor: 'rgba(0,160,233,0.2)',
            borderColor: 'rgba(0,160,233,1)',
            pointBorderColor: 'rgba(0,160,233,1)',
            pointBackgroundColor: '#fff'
          }
        ]
      },
      options: LINE_CHART_OPTIONS
    }),
    sd_statistics: new Chart($('#sd_statistics'), {
      type: 'line',
      data: {
        labels: [],
        datasets: [
          {
            label: ['Have'],
            data: [],
            lineTension: 0,
            backgroundColor: 'rgba(0,160,233,0.2)',
            borderColor: 'rgba(0,160,233,1)',
            pointBorderColor: 'rgba(0,160,233,1)',
            pointBackgroundColor: '#fff'
          }
        ]
      },
      options: LINE_CHART_OPTIONS
    })
  };

  let currentDate = cal.val();

  let draw_pies = function (json) {
    let score_rank = json.reduce(function (memo, x) {
      memo[x.rank] += 1;

      return memo;
    }, {A: 0, B: 0, C: 0, D: 0, E: 0});

    let alive = json.reduce(function (memo, x) {
      memo[x.alive] += 1;

      return memo;
    }, {true: 0, false: 0});

    let sd = json.reduce(function (memo, x) {
      memo[x.service_description] += 1;

      return memo;
    }, {true: 0, false: 0});

    canvas.score_rank.data.datasets[0].data = Object.values(score_rank);
    canvas.alive.data.datasets[0].data = Object.values(alive);
    canvas.sd.data.datasets[0].data = Object.values(sd);

    canvas.score_rank.update();
    canvas.alive.update();
    canvas.sd.update();
  };

  let draw_lines = function (json) {
    let labels = Object.keys(json);
    let values = Object.values(json);
    let average = values.map(x => x[0]);
    let median = values.map(x => x[1]);
    let alive = values.map(x => x[2]);
    let sd = values.map(x => x[3]);

    canvas.score_statistics.data.labels = labels;
    canvas.alive_statistics.data.labels = labels;
    canvas.sd_statistics.data.labels = labels;

    canvas.score_statistics.data.datasets[0].data = average;
    canvas.score_statistics.data.datasets[1].data = median;
    canvas.alive_statistics.data.datasets[0].data = alive;
    canvas.sd_statistics.data.datasets[0].data = sd;

    canvas.score_statistics.update();
    canvas.alive_statistics.update();
    canvas.sd_statistics.update();
  };

  let draw_scores = function (date) {
    $.when(
      $.ajax({
        type: 'GET',
        dataType: 'json',
        contentType: 'application/json; charset=UTF-8',
        url: Routes.endpoint_index_path({date: date}),
        timeout: 10000 // 10 sec
      }),
      $.ajax({
        type: 'GET',
        dataType: 'json',
        contentType: 'application/json; charset=UTF-8',
        url: Routes.endpoint_statistics_path({date: date}),
        timeout: 10000 // 10 sec
      })
    ).done(function (first, second) {
      draw_pies(first[0].data);
      draw_lines(second[0]);
      currentDate = date;
    }).fail(function (jqXHR, textStatus, errorThrown) {
      window.alert(`${textStatus}: ${jqXHR.status} ${errorThrown}`);
      cal.val(currentDate);
    });
  };

  $('#update-date').on('click', function () {
    draw_scores(cal.val());
  });

  draw_scores(currentDate);
});
