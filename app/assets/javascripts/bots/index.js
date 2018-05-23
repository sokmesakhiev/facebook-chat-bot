"use strict";

$(document).on('turbolinks:load', function() {
  init();

  function init() {
    _onActivateBot();
    _onDeactivateBot();
  }

  function _onActivateBot() {
    $('.activate').on('click', function(e) {
      var bot = $(this).data('bot')
      _update(bot.id, 'activate');
    })
  }

  function _onDeactivateBot() {
    $('.deactivate').on('click', function(e) {
      var result = confirm("Are you sure you want to deactivate this bot?");

      if (result) {
        var bot = $(this).data('bot');
        _update(bot.id, 'deactivate');
      }
    })
  }

  function _update(bot_id, action) {
    var token = $('[name="authenticity_token"]').val();

    $.ajax({
      url: '/bots/'+ bot_id +'/' + action,
      type: 'PUT',
      data: 'authenticity_token=' + token,
      success: function(data) {
      }
    });
  }
})
