function formatDate(label) {
  var clickedDate = new Date(label);
  return ("0" + (clickedDate.getMonth() + 1)).slice(-2) + "/" + ("0" + clickedDate.getDate()).slice(-2);
}

function make_scale_options(max) {
  return {
    scales: {
      yAxes: [{
        ticks: {
          max: max += 10,
          min: 0
        },
        afterBuildTicks: function(scale) {
          scale.ticks = [];
          var interval = max / 5
          var rounded = Math.round((interval / 10)) * 10
          for (var i = 0; i < max; i += rounded) {
            scale.ticks.push(i)
          }
        }
      }]
    }
  }
}
