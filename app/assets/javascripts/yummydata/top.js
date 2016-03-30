$(function() {
  var drawScores = $.getJSON("endpoints/scores", function(json) {
    data = make_score_data(json)
    showPie($("#score")[0].getContext("2d"), data);
  });
  var drawAlive = $.getJSON("endpoints/alive", function(json) {
    data = make_alive_data(json)
    showPie($("#alive")[0].getContext("2d"), data);
  });
  var drawSd = $.getJSON("endpoints/service_descriptions", function(json) {
    showPie($("#sd")[0].getContext("2d"), json);
  });

  setTimeout(function(){ drawScores.abort(); }, 10000);
  setTimeout(function(){ drawAlive.abort(); }, 10000);
  setTimeout(function(){ drawSd.abort(); }, 10000);
});

function make_score_data(count) {
  return [
      {
        value: count[5],
        color: "#1D2088",
        highlight: "#6356A3",
        label: "Rank A"
      },
      {
        value: count[4],
        color: "#00A0E9",
        highlight: "#00B9EF",
        label: "Rank B"
      },
      {
        value: count[3],
        color: "#009944",
        highlight: "#03EB37",
        label: "Rank C"
      },
      {
        value: count[2],
        color: "#FFF100",
        highlight: "#FFF462",
        label: "Rank D"
      },
      {
        value: count[1],
        color: "#E60012",
        highlight: "#FF5A5E",
        label: "Rank E"
      }
    ]
}

function make_alive_data(count) {
  return [
    {
      value: count['alive'],
      color: "#00A0E9",
      highlight: "#00B9EF",
      label: "Alive"
    },
    {
      value: count['dead'],
      color: "#E60012",
      highlight: "#FF5A5E",
      label: "Dead"
    }
  ]
}

function showPie(context, data) {
  new Chart(context).Pie(data);
}
function showLine(context, data) {
  new Chart(context).Line(data, {
    bezierCurve: false,
  });
}
