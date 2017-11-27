$(function() {
  var input_date = $("#calendar").val();
  var param = (input_date == '') ? '' : '/?date=' + input_date
  var drawScores = $.getJSON("/endpoints/scores" + param, function(json) {
    data = make_score_data(json);
    showBar("#score", data);
  });

  setTimeout(function(){ drawScores.abort(); }, 10000);

  $('.carousel').carousel({
    interval: 10000
  })

});

function make_score_data(count) {
  return {
    labels: ['Rank A', 'Rank B', 'Rank C', 'Rank D', 'Rank E'],
    datasets: [
      {
        data: [count[5], count[4], count[3], count[2], count[1]],
        backgroundColor: ['#FF3D7F', '#3FB8AF', '#7FC7AF', '#FF9E9D', '#DAD8A7'],
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
            display: false,
          },
          ticks: {
            min: 0
          }
        }]
      }
    }
  });
}
