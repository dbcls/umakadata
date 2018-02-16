//= require bootstrap-datepicker.min
//= require Chart.min
//= require umakadata/chart-helper
//= require umakadata/twitter-widget

function make_score_data(count) {
  return {
    labels: ['Rank A', 'Rank B', 'Rank C', 'Rank D', 'Rank E'],
    datasets: [
      {
        data: [count[5], count[4], count[3], count[2], count[1]],
        backgroundColor: ['#FF3D7F', '#3FB8AF', '#7FC7AF', '#FF9E9D', '#DAD8A7']
      }
    ],
    options: {}
  };
}

function showBar(id, data) {
  new Chart($(id), {
    type: 'bar',
    data: data,
    options: {
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
}

function drawScores() {
  var input_date = $('#calendar').val();
  var param = (input_date === '') ? '' : '/?date=' + input_date;
  var f = $.getJSON("/endpoints/scores" + param, function (json) {
    showBar("#score", make_score_data(json));
  });

  setTimeout(function () {
    f.abort();
  }, 10000);
}

$(document).ready(function() {
  $('#jump-button').on("click", function () {
    var input_date = $("#calendar").val();
    var param = (input_date === '') ? '' : '?date=' + input_date;
    location.href = "/" + param
  });

  drawScores();

  $('.carousel').carousel({
    interval: 10000
  });
});
