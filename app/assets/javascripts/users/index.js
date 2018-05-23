"use strict";

$(document).on('turbolinks:load', function() {
  init();

  function init() {
    _onOpenUserModal();
    _onCloseUserModal();
    _onActivateUser();
    _onDeactivateUser();
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

  function _onActivateUser() {
    $('.activate-user').on('click', function(e) {
      var user = $(this).data('user')
      _update(user.id, 'activate');
    })
  }

  function _onDeactivateUser() {
    $('.deactivate-user').on('click', function(e) {
      var result = confirm("Are you sure you want to deactivate this user?");

      if (result) {
        var user = $(this).data('user');
        _update(user.id, 'deactivate');
      }
    })
  }

  function _update(user_id, action) {
    var token = $('[name="authenticity_token"]').val();

    $.ajax({
      url: '/users/'+ user_id +'/' + action,
      type: 'PUT',
      data: 'authenticity_token=' + token,
      success: function(data) {
      }
    });
  }
})
