"use strict";

$(document).on('turbolinks:load', function() {
  init();

  function init() {
    _onOpenUserModal();
    _onCloseUserModal();
  }

  function _onOpenUserModal() {
    $('#user-modal').on('shown.bs.modal', function (event) {
      var button = $(event.relatedTarget);
      var user = button.data('user');
      var modal = $(this);
      var emailInput = modal.find('.modal-content #user_email');

      if (!user) {
        emailInput.focus();
        return;
      }

      modal.find('.modal-content [name="authenticity_token"]').append($('<input name="_method" type="hidden" value="patch">'))
      modal.find('.modal-content form').attr('action', '/users/' + user.id);
      modal.find('.modal-content #user_role').val(user.role);
      emailInput.val(user.email).focus();
    })
  }

  function _onCloseUserModal() {
    $('#user-modal').on('hide.bs.modal', function (event) {
      var modal = $(this);

      modal.find('.modal-content #user_email').val('');
      modal.find('.modal-content #user_role').val('user');
      modal.find('.modal-content form').attr('action', '/users');
      modal.find('.modal-content [name="_method"]').remove();
    })
  }
})
