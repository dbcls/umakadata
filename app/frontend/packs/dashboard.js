import 'bootstrap/js/dist/carousel';
import 'bootstrap-datepicker/dist/js/bootstrap-datepicker.min';
import Chart from 'chart.js';
import Routes from '../javascripts/js-routes.js.erb';

import '../stylesheets/dashboard';

(function () {
  const scoreChartOptions = {
    type: 'bar',
    data: {
      labels: ['Rank A', 'Rank B', 'Rank C', 'Rank D', 'Rank E'],
      datasets: [
        {
          backgroundColor: ['#FF3D7F', '#3FB8AF', '#7FC7AF', '#FF9E9D', '#DAD8A7']
        }
      ],
    },
    options: {
      responsive: true,
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
  };

  const drawScoreChart = function () {
    const $scoreHistogram = $('#score-histogram');

    const ctx = $scoreHistogram;
    const container = ctx.parent();
    const width = container.width() - 80;

    ctx.attr('width', width);
    ctx.attr('height', width * 2 / 3);

    const chart = new Chart(ctx, scoreChartOptions);
    const data = $scoreHistogram.data('scores');

    chart.data.datasets[0].data = Object.values(data);
    chart.update();
  };

  $('#scores').carousel({
    interval: 10000,
    ride: 'carousel'
  });

  const $calendar = $('#calendar');

  $calendar.datepicker({
    autoclose: true,
    startDate: $calendar.data('start-date'),
    endDate: $calendar.data('end-date'),
    format: 'yyyy-mm-dd',
    todayHighlight: true
  });

  $('#update-date').on('click', function () {
    window.location = Routes.root_path({date: $calendar.val()});
  });

  drawScoreChart();
})();
