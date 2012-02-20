# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

jQuery ->
  $("#add_contact").click (e) ->
      contact_id = $("#contacts_select").val()
      if contact_id
        contact_email = $("#contacts_select option:selected").text()
        selector = $("li#contact_" + contact_id)
        mark_primary = ($("li[id^=contact_]").length == 0)

        if selector.length is 0
          $('<li>').attr('id','contact_' + contact_id).appendTo("ul#contacts_list")

          $('<input type=hidden>').attr(
            name: 'contact_ids[]'
            value: contact_id
          ).appendTo('li#contact_' + contact_id)

          $('<input type=radio>').attr(
            name: 'contact_primary'
            value: contact_id
            id: 'contact_primary_' + contact_id
            checked: mark_primary
          ).appendTo('li#contact_' + contact_id)


          $('li#contact_' + contact_id).append(contact_email)
          $('li#contact_' + contact_id).append("<a href='#' class='delete_contact delete_link'>Delete</a>")

          $('<span>').attr(
            name: 'remove_contact'
            class: 'remove_button'
          ).appendTo('li#contact_' + contact_id)

      e.preventDefault()

  $(".delete_contact").live "click", ->
    $(this).parent().remove()
    if $("form :radio[name=contact_primary]:checked").length == 0
      $('form :radio[name=contact_primary]:first').attr(
        checked: true
      )
    false


#      $("ul#contacts_list").append "<li id='contact_" + contact_id + "'>"+
#          "<input type='hidden' name='contact_ids[]' value='" + contact_id + "'>" +
#          "<input type='checkbox' name='project[collaborating][" + contact_id + "]' class='basic_field'>"+
#          "<input type='hidden' name='project[contact_ids][]' value='" + contact_id + "'>" +
#          contact_email +
#          "<span name='remove_contact' class='remove_button basic_field'></span></li>"
#  $("#contact", "#<%= dialog_id %>").val ""
#  false