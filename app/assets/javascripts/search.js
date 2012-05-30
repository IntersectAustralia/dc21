$(function () {
  var hidden_selects = true;
  $('.searchcategory .date').hide();
  $('.searchcategory .time').hide();
  $('.searchcategory .facility').hide();
  $('.searchcategory .variable').hide();
  $('.searchcategory .description').hide();
  $('.searchcategory .filename').hide();
  $('.searchcategory .tags').hide();
  $('.searchcategory .type').hide();
  $('.searchcategory .uploader').hide();
  $('.searchcategory .upload_date').hide();

  $('#date').click(function (event) {
    $('.date').slideToggle();
    $(this).toggleClass('current');
  });

  $('#time').click(function (event) {
    $('.time').slideToggle();
    $(this).toggleClass('current');
  });

  $('#facility').click(function (event) {
    $('.facility').slideToggle();
    $(this).toggleClass('current');
  });

  $('#variable').click(function (event) {
    $('.variable').slideToggle();
    $(this).toggleClass('current');
  });

  $('#filename_category').click(function (event) {
    $('.filename').slideToggle();
    $(this).toggleClass('current');
  });

  $('#description_category').click(function (event) {
    $('.description').slideToggle();
    $(this).toggleClass('current');
  });

  $('#type_category').click(function (event) {
    $('.type').slideToggle();
    $(this).toggleClass('current');
  });

  $('#tags_category').click(function (event) {
    $('.tags').slideToggle();
    $(this).toggleClass('current');
  });

  $('#uploader').click(function (event) {
    $('.uploader').slideToggle();
    $(this).toggleClass('current');
  });

  $('#upload_date').click(function (event) {
    $('.upload_date').slideToggle();
    $(this).toggleClass('current');
  });


  // DOWNLOAD MULTIPLE TOGGLE
  $('#downloadtoggle').click(function (event) {
    if (hidden_selects == true) {
      hidden_selects = false;
      $('.select').show();
      display_actions();
    } else {
      hidden_selects = true;
      $('.select').hide();
      $('#download_actions').hide();
    }
    return false;
  });

  // SHOW DOWNLOAD BUTTONS ON SELECTION
  $('input:checkbox', '#exploredata').click(function () {
    display_actions();
  });

});

// SELECT ALL / NONE - DOWNLOAD MULTIPLE //////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////

function display_actions() {
  var buttonsChecked = $('#exploredata').find('input:checkbox:checked');
  if (buttonsChecked.length) {
    $('#download_actions').show();
  } else {
    $('#download_actions').hide();
  }
}

function selectToggle(checked, form) {
  var dataForm = document.forms[form];
  for (var i = 0; i < dataForm.length; i++) {
    if (checked) {
      dataForm.elements[i].checked = "";
      $('#download_actions').hide();
    }
    else {
      dataForm.elements[i].checked = "checked";
      $('#download_actions').show();

    }
  }
}