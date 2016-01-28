$(function() {
  var drawScores = $.getJSON("endpoints/scores", function(json) {
    showPie($("#score")[0].getContext("2d"), json);
  });
  var drawAlive = $.getJSON("endpoints/alive", function(json) {
    showPie($("#alive")[0].getContext("2d"), json);
  });
  var drawSd = $.getJSON("endpoints/service_descriptions", function(json) {
    showPie($("#sd")[0].getContext("2d"), json);
  });

  setTimeout(function(){ drawScores.abort(); }, 10000);
  setTimeout(function(){ drawAlive.abort(); }, 10000);
  setTimeout(function(){ drawSd.abort(); }, 10000);
});
function showPie(context, data) {
  new Chart(context).Pie(data);
}
function showLine(context, data) {
  new Chart(context).Line(data, {
    bezierCurve: false,
  });
}
