$(document).ready(function(){

  $("#facility_add_contact").on('click', function(event) {
    var contact_email, contact_id;
    contact_id = $("#other_contacts_select option:selected").val();
    contact_email = $("#other_contacts_select option:selected").text();

    var selector = "li#contact_" + contact_id;

    if (!$(selector).length && isNotPrimary()) {
      addContact(contact_id, contact_email, selector);
    }

    return event.preventDefault();
  });

  $("#primary_contact_select").on('change', removePrimaryInList);

  $(".delete_contact").live('click', function(){
    $(this).parent().remove();
    return false;
  });

  function isNotPrimary() {
    var primary_contact = $("#primary_contact_select option:selected").val();
    var current_contacts = $("#other_contacts_select option:selected").val();
    return primary_contact != current_contacts
  }

  function removePrimaryInList() {
    var primary_contact = $("#primary_contact_select option:selected").val();
    var current_contacts = [];
    $("#contacts_list").find('li').each(function() {
      current_contacts.push($(this).attr('id'));
    });

    if ($.inArray("contact_" + primary_contact, current_contacts) >= 0) {
      var contact_id = "#contact_" + primary_contact;
      $(contact_id).remove();
    }
  }

  function addContact(contact_id, contact_email, selector) {
    var id = "contact_" + contact_id;

    $('<li>').attr("id", id).appendTo("ul#contacts_list");
    $('<input type=hidden>').attr({name: 'facility[contact_ids][]', value: contact_id}).appendTo(selector);
    $(selector).append('<span>' + contact_email + '</span>');
    $(selector).append("<a href='#' class='delete_contact delete_link'> Delete</a>");
    $('<span>').attr({name: 'remove_contact', "class": 'remove_button'}).appendTo(selector);
  }

});