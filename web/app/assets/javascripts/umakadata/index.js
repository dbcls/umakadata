//= require Chart.min
//= require bootstrap-datepicker.min
//= require umakadata/chart-helper

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
    labels: labels.map(formatDate),
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
    labels: labels.map(formatDate),
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
    labels: labels.map(formatDate),
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
  return new Chart($(context), {
    type: 'line',
    data: data,
    options: options
  });
}

function addGraphClickEvent(context, lineChart, labels, pathname) {
  $(context).on("click", function (evt) {
    var activePoints = lineChart.getElementsAtEvent(evt);
    if (activePoints.length === 0) {
      return
    }
    var index = activePoints[0]['_index'];
    var datestring = labels[index];
    var clickedDate = new Date(datestring);
    var clickedDateFormat = clickedDate.getUTCFullYear() + "-" + ("0" + (clickedDate.getUTCMonth() + 1)).slice(-2) + "-" + ("0" + (clickedDate.getUTCDate())).slice(-2);
    location.href = location.protocol + "//" + location.host + pathname + "?date=" + clickedDateFormat;
  });
}

function getDateFromURLQuery() {
  var hash = {};
  var query = window.location.search.substring(1);
  var vars = query.split("&");
  for (var i = 0; i < vars.length; i++) {
    var pair = vars[i].split("=");
    if (pair[0] === 'date') {
      hash['date'] = pair[1];
    }
  }
  return hash;
}

function createParams(values) {
  var list = [];
  for (var key in values) {
    list.push(key + "=" + values[key]);
  }
  return list.join("&");
}

function drawUmakaScores() {
  var input_date = $("#calendar").val();
  var param = (input_date === '') ? '' : '/?date=' + input_date;

  var drawScores = $.getJSON("/endpoints/scores" + param, function (json) {
    var data = make_score_data(json);
    showPie("#score", data);
  });
  var drawAlive = $.getJSON("/endpoints/alive" + param, function (json) {
    var data = make_alive_data(json);
    showPie("#alive", data);
  });
  var drawSd = $.getJSON("/endpoints/service_descriptions" + param, function (json) {
    var data = make_sd_data(json);
    showPie("#sd", data);
  });
  var drawScoreStatistics = $.getJSON("/endpoints/score_statistics" + param, function (json) {
    var labels = json['labels'];
    var datasets = json['datasets'];
    var data = make_score_statistics_data(labels, datasets);
    var canvas_id = "#score_statistics";
    var lineChart = showLine(canvas_id, data, make_scale_options());
    addGraphClickEvent(canvas_id, lineChart, labels, location.pathname);
  });
  var drawAliveStatistics = $.getJSON("/endpoints/alive_statistics" + param, function (json) {
    var labels = json['labels'];
    var datasets = json['datasets'];
    var data = make_alive_statistics_data(labels, datasets);
    var canvas_id = "#alive_statistics";
    var lineChart = showLine(canvas_id, data, make_scale_options());
    addGraphClickEvent(canvas_id, lineChart, labels, location.pathname);
  });
  var drawSdStatistics = $.getJSON("/endpoints/service_description_statistics" + param, function (json) {
    var labels = json['labels'];
    var datasets = json['datasets'];
    var data = make_sd_statistics_data(labels, datasets);
    var canvas_id = "#sd_statistics";
    var lineChart = showLine(canvas_id, data, make_scale_options());
    addGraphClickEvent(canvas_id, lineChart, labels, location.pathname);
  });

  setTimeout(function () {
    drawScores.abort();
  }, 10000);
  setTimeout(function () {
    drawAlive.abort();
  }, 10000);
  setTimeout(function () {
    drawSd.abort();
  }, 10000);
  setTimeout(function () {
    drawScoreStatistics.abort();
  }, 10000);
  setTimeout(function () {
    drawAliveStatistics.abort();
  }, 10000);
  setTimeout(function () {
    drawSdStatistics.abort();
  }, 10000);
}

function drawScoreRanking(hash) {
  var params = createParams(hash);
  var query = '/?' + params;

  var score_ranking = $.getJSON("endpoints/score_ranking" + query, function (data) {
    var result_body = $('#result_body');
    result_body.empty();
    for (var i = 0; i < data.length; i++) {
      var endpoint = data[i];
      var evaluation_id = endpoint[0];
      var endpoint_id = endpoint[1];
      var name = endpoint[2];
      var url = endpoint[3];
      var score = endpoint[4];
      var row = $("<tr>");
      row.append($("<td>").append($("<a>").attr("href", "/endpoints/" + endpoint_id + "/" + evaluation_id).text(name)));
      row.append($("<td>").append($("<a>").attr("href", url).text(url)));
      row.append($("<td>").text(score));
      result_body.append(row);
    }
  });

  setTimeout(function () {
    score_ranking.abort();
  }, 10000);
}

$(document).ready(function() {
  $('#jump-button').on("click", function () {
    var input_date = $("#calendar").val();
    var param = (input_date === '') ? '' : '?date=' + input_date;
    location.href = "/endpoints/" + param
  });

  $('.column').on('click', function () {
    var column = $(this).text().trim().toLowerCase();
    var dir = $(this).attr('data-direction');
    var type = dir === undefined ? column === 'score' ? 'ASC' : 'DESC' : dir === 'ASC' ? 'DESC' : 'ASC';
    $(this).attr('data-direction', type);

    var hash = getDateFromURLQuery();
    hash['column'] = column;
    hash['direction'] = type;

    drawScoreRanking(hash);
  });

  drawUmakaScores();
  drawScoreRanking();
});
