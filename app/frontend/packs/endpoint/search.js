import 'bootstrap/dist/js/bootstrap';
import 'bootstrap-datepicker/dist/js/bootstrap-datepicker.min';

import '../../stylesheets/endpoint';

$(function () {
  let $calendar = $('#search_form_date');

  $calendar.datepicker({
    autoclose: true,
    startDate: $calendar.data('start-date'),
    endDate: $calendar.data('end-date'),
    format: 'yyyy-mm-dd',
    todayHighlight: true
  });
});
