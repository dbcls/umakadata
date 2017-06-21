var waitingDialog = waitingDialog || (function ($) {
        'use strict';

        var $dialog = $(
            '<div class="modal fade" data-backdrop="static" data-keyboard="false" tabindex="-1" role="dialog" aria-hidden="true" style="padding-top:15%; overflow-y:visible;">' +
            '<div class="modal-dialog modal-m">' +
            '<div class="modal-content">' +
            '<div class="modal-header"><h3 style="margin:0;"></h3></div>' +
            '<div class="modal-body">' +
            '<div class="progress progress-striped active" style="margin-bottom:0;"><div class="progress-bar" style="width: 100%"></div></div>' +
            '</div>' +
            '</div></div></div>');
        return {
            show: function (message, options) {
                // Assigning defaults
                if (typeof options === 'undefined') {
                    options = {};
                }
                if (typeof message === 'undefined') {
                    message = 'Loading';
                }
                var settings = $.extend({
                    dialogSize: 'm',
                    progressType: '',
                    onHide: null // This callback runs after the dialog was hidden
                }, options);

                $dialog.find('.modal-dialog').attr('class', 'modal-dialog').addClass('modal-' + settings.dialogSize);
                $dialog.find('.progress-bar').attr('class', 'progress-bar');
                if (settings.progressType) {
                    $dialog.find('.progress-bar').addClass('progress-bar-' + settings.progressType);
                }
                $dialog.find('h3').text(message);

                if (typeof settings.onHide === 'function') {
                    $dialog.off('hidden.bs.modal').on('hidden.bs.modal', function (e) {
                        settings.onHide.call($dialog);
                    });
                }

                $dialog.modal();
            },
            hide: function () {
                $dialog.modal('hide');
            }
        };
    })(jQuery);

var dataLoader = (function ($) {
    var raderLoaded = false;
    var scoreLoaded = false;

    return {
        load: function (endpoint_id, evaluation_id) {
            raderLoaded = false;
            scoreLoaded = false;
            waitingDialog.show('Loading Endpoint Information...');
            dataLoader.showInfo(endpoint_id, evaluation_id);
        },

        done: function() {
            if (raderLoaded && scoreLoaded) {
                waitingDialog.hide();

                $('#jump-button').on("click", function () {
                    var input_date = $("#calendar").val();
                    var param = (input_date == '') ? '' : '?date=' + input_date;
                    $.getJSON("/api/endpoints/" + endpoint_id + "/created_at" + param, function (json) {
                        var evaluation_id = json['evaluation_id'];
                        if (evaluation_id == '') {
                            $('#get_evaluation_id').modal();
                        } else {
                            location.href = "/endpoints/" + endpoint_id + "/" + evaluation_id + param
                        }
                    });
                });
            }
        },

        showInfo: function(endpoint_id, evaluation_id) {
            $.ajax({
                type: "GET",
                url: "/endpoints/" + endpoint_id + "/" + evaluation_id + "/info",
                success: function (element) {
                    var html = $.parseHTML(element);
                    $("#endpoint_info").html(html);
                    dataLoader.showRadar(endpoint_id, evaluation_id);
                    dataLoader.showScoreHistory(endpoint_id, evaluation_id);
                }
            });
        },

        showRadar: function (endpoint_id, evaluation_id) {
            $.getJSON("/endpoints/" + endpoint_id + "/" + evaluation_id + "/radar", function (json) {
                var data = json['data'];
                var avg = json['avg'];
                var context = $("#radar");
                var labels = ["availability", "freshness", "operation", "usefulness", "validity", "performance"];
                new Chart(context, {
                    type: 'radar',
                    data: {
                        labels: labels,
                        datasets: [
                            {
                                label: "Target",
                                backgroundColor: "rgba(151,187,205,0.2)",
                                borderColor: "rgba(151,187,205,1)",
                                pointBorderColor: "rgba(151,187,205,1)",
                                pointBackgroundColor: "#fff",
                                data: data
                            },
                            {
                                label: "Average",
                                backgroundColor: "rgba(220,220,220,0.5)",
                                borderColor: "rgba(220,220,220,1)",
                                pointBorderColor: "rgba(220,220,220,1)",
                                pointBackgroundColor: "#fff",
                                data: avg
                            }
                        ]
                    },
                    options: {
                        responsive: true
                    }
                });
                dataLoader.setScoresOnLabels(labels, data);
                raderLoaded = true;
                dataLoader.done();
            });
        },

        setScoresOnLabels: function (labels, data) {
            var status;
            for (var i = 0; i < 6; ++i) {
                $('#' + labels[i] + '_score').text('(' + data[i] + ')');
                if (data[i] < 20) {
                    status = 'poor';
                } else if (data[i] < 40) {
                    status = 'below_average'
                } else if (data[i] < 60) {
                    status = 'average'
                } else if (data[i] < 80) {
                    status = 'good'
                } else {
                    status = 'excellent';
                }
                $('.' + labels[i]).addClass(status)
            }
        },

        appendOptions: function (datasets) {
            datasets['datasets'].forEach(function (element) {
                var label = element['label'];

                if (label) {
                    element['lineTension'] = 0;
                    // set all 'pointBackgroundColor' to white
                    element['pointBackgroundColor'] = 'rgba(255, 255, 255, 1)';
                    // set the area under the line not to fill
                    element['fill'] = false;
                }

                switch (label.toLowerCase()) {
                    case 'availability':
                        element['backgroundColor'] = 'rgba(220, 220, 220, 0.2)';
                        element['borderColor'] = element['pointBorderColor'] = 'rgba(220, 220, 220, 1)';
                        break;
                    case 'freshness':
                        element['backgroundColor'] = 'rgba(54, 162, 235, 0.2)';
                        element['borderColor'] = element['pointBorderColor'] = 'rgba(54, 162, 235, 1)';
                        break;
                    case 'operation':
                        element['backgroundColor'] = 'rgba(255, 99, 132, 0.2)';
                        element['borderColor'] = element['pointBorderColor'] = 'rgba(255, 99, 132, 1)';
                        break;
                    case 'usefulness':
                        element['backgroundColor'] = 'rgba(255, 206, 86, 0.2)';
                        element['borderColor'] = element['pointBorderColor'] = 'rgba(255, 206, 86, 1)';
                        break;
                    case 'validity':
                        element['backgroundColor'] = 'rgba(75, 192, 192, 0.2)';
                        element['borderColor'] = element['pointBorderColor'] = 'rgba(75, 192, 192, 1)';
                        break;
                    case 'performance':
                        element['backgroundColor'] = 'rgba(21, 7, 119, 0.2)';
                        element['borderColor'] = element['pointBorderColor'] = 'rgba(21, 7, 119, 1)';
                        break;
                    case 'rank':
                        element['backgroundColor'] = 'rgba(151, 187, 205, 0.2)';
                        element['borderColor'] = element['pointBorderColor'] = 'rgba(151, 187, 205, 1)';
                        break;
                    default:
                        break;
                }
            });
        },

        showScoreHistory: function (endpoint_id, evaluation_id) {
            $.getJSON("/endpoints/" + endpoint_id + "/" + evaluation_id + "/score_history", function (json) {
                var context = $("#score_history");
                dataLoader.appendOptions(json);
                var labels = json['labels'];
                json['labels'] = labels.map(formatDate);
                var options = make_scale_options()
                options['datasetFill'] = false
                var lineChart = new Chart(context, {
                    type: 'line',
                    data: json,
                    options: options
                });
                dataLoader.addGraphClickEvent(context, lineChart, labels, endpoint_id);
                scoreLoaded = true;
                dataLoader.done();
            });
        },

        addGraphClickEvent: function (context, lineChart, labels, endpoint_id) {
            $(context).on("click", function (evt) {
                var activePoints = lineChart.getElementsAtEvent(evt);
                if (activePoints.length == 0) {
                    return
                }
                var index = activePoints[0]['_index'];
                var datestring = labels[index];
                var clickedDate = new Date(datestring);
                $.getJSON("/api/endpoints/" + endpoint_id + "/created_at?date=" + datestring, function (json) {
                    var evaluation_id = json['evaluation_id']
                    if (evaluation_id == '') {
                        $('#get_evaluation_id').modal();
                    } else {
                        location.href = location.protocol + "//" + location.host + '/endpoints/' + endpoint_id + '/' + evaluation_id + "?date=" + datestring
                    }
                });
            });
        },
    }
})(jQuery);

$(function () {
    var endpoint_id = $('#endpoint_id').text().trim();
    var evaluation_id = $('#evaluation_id').text().trim();

    dataLoader.load(endpoint_id, evaluation_id);
});
