"use strict";

$(document).on('turbolinks:load', function() {
  $('#preview').on('shown.bs.modal', function () {
    console.log('preview')
  })

  $('#re-import').on('shown.bs.modal', function () {
    console.log('re import')
  })
});
