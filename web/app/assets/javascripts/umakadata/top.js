$(function() {
  var drawScores = $.getJSON("endpoints/scores", function(json) {
    data = make_score_data(json)
    showPie("#score", data);
  });
  var drawAlive = $.getJSON("endpoints/alive", function(json) {
    data = make_alive_data(json)
    showPie("#alive", data);
  });
  var drawSd = $.getJSON("endpoints/service_descriptions", function(json) {
    data = make_sd_data(json)
    showPie("#sd", data);
  });

  setTimeout(function(){ drawScores.abort(); }, 10000);
  setTimeout(function(){ drawAlive.abort(); }, 10000);
  setTimeout(function(){ drawSd.abort(); }, 10000);

  var drawScoreStatistics = $.getJSON("endpoints/score_statistics", function(json) {
    var labels = json['labels'];
    var datasets = json['datasets'];
    data = make_score_statistics_data(labels, datasets)
    showLine("#score_statistics", data, make_scale_options(100));
  });
  var drawAliveStatistics = $.getJSON("endpoints/alive_statistics", function(json) {
    var labels = json['labels'];
    var datasets = json['datasets'];
    data = make_alive_statistics_data(labels, datasets)
    var max = select_max_from_data(datasets[0]['data'])
    showLine("#alive_statistics", data, make_scale_options(max));
  });
  var drawSdStatistics = $.getJSON("endpoints/service_description_statistics", function(json) {
    var labels = json['labels'];
    var datasets = json['datasets'];
    data = make_sd_statistics_data(labels, datasets)
    var max = select_max_from_data(datasets[0]['data'])
    showLine("#sd_statistics", data, make_scale_options(max));
  });

  setTimeout(function(){ drawScoreStatistics.abort(); }, 10000);
  setTimeout(function(){ drawAliveStatistics.abort(); }, 10000);
  setTimeout(function(){ drawSdStatistics.abort(); }, 10000);
});

function make_score_data(count) {
  return {
    labels: ['Rank A', 'Rank B', 'Rank C', 'Rank D', 'Rank E'],
    datasets: [
      {
        data: [count[5], count[4], count[3], count[2], count[1]],
        backgroundColor: ['#1D2088', '#00A0E9', '#009944', '#FFF100', '#E60012'],
        hoverBackgroundColor: ['#6356A3', '#00B9EF', '#03EB37', '#FFF462', '#FF5A5E']
      }
    ],
    options: {
      legend: false
    }
  };
}
function make_alive_data(count) {
  return {
    labels: ['Alive', 'Dead'],
    datasets: [
      {
        data: [
          count['alive'],
          count['dead']
        ],
        backgroundColor: [
          '#00A0E9',
          '#E60012'
        ],
        hoverBackgroundColor: [
          '#00B9EF',
          '#FF5A5E'
        ]
      }
    ]
  };
}
function make_sd_data(count) {
  return {
    labels: ['Have', 'Do not have'],
    datasets: [
      {
        data: [
          count['true'],
          count['false']
        ],
        backgroundColor: [
          '#00A0E9',
          '#E60012'
        ],
        hoverBackgroundColor: [
          '#00B9EF',
          '#FF5A5E'
        ]
      }
    ]
  };
}
function make_score_statistics_data(labels, datasets) {
  return {
    labels: labels,
    datasets: [
      {
        label: datasets[0]['label'],
        lineTension: 0,
        backgroundColor: 'rgba(0,160,233,0.2)',
        borderColor: 'rgba(0,160,233,1)',
        pointBorderColor: 'rgba(0,160,233,1)',
        pointBackgroundColor: '#fff',
        data: datasets[0]['data']
      },
      {
        label: datasets[1]['label'],
        lineTension: 0,
        backgroundColor: 'rgba(255, 99, 132, 0.2)',
        borderColor: 'rgba(255, 99, 132,1)',
        pointBorderColor: 'rgba(255, 99, 132,1)',
        pointBackgroundColor: '#fff',
        data: datasets[1]['data']
      }
    ]
  }
}
function make_alive_statistics_data(labels, datasets) {
  return {
    labels: labels,
    datasets: [
      {
        label: datasets[0]['label'],
        lineTension: 0,
        backgroundColor: 'rgba(0,160,233,0.2)',
        borderColor: 'rgba(0,160,233,1)',
        pointBorderColor: 'rgba(0,160,233,1)',
        pointBackgroundColor: '#fff',
        data: datasets[0]['data']
      }
    ]
  }
}

function make_sd_statistics_data(labels, datasets) {
  return {
    labels: labels,
    datasets: [
      {
        label: datasets[0]['label'],
        lineTension: 0,
        backgroundColor: 'rgba(0,160,233,0.2)',
        borderColor: 'rgba(0,160,233,1)',
        pointBorderColor: 'rgba(0,160,233,1)',
        pointBackgroundColor: '#fff',
        data: datasets[0]['data']
      }
    ]
  }
}

function make_scale_options(max) {
  return {
    scales: {
      yAxes: [{
        ticks: {
          max: max += 10,
          min: 0
        }
      }]
    }
  }
}

function select_max_from_data(data) {
  var max = Math.max(...data)
  return (max > 100) ? max : 100
}

function showPie(id, data) {
  new Chart($(id), {
    type: 'pie',
    data: data,
    options: {
      animation: {
        animateScale: true
      }
    }
  });
}

function showLine(context, data, options) {
  new Chart($(context), {
    type: 'line',
    data: data,
    options: options
  });
}
