$(function () {
    var hidden_selects = true;
    if ($('#date_visible').val() == "false") {
        $('.searchcategory .date').hide();
    }
    else {
        $('#date').toggleClass('current');
    }
    $('.searchcategory .time').hide();
    if ($('#facility_visible').val() == "false") {
        $('.searchcategory .facility').hide();
    }
    else {
        $('#facility').toggleClass('current');
    }
    if ($('#variable_visible').val() == "false") {
        $('.searchcategory .variable').hide();
    }
    else {
        $('#variable').toggleClass('current');
    }
    if ($('#description_visible').val() == "false") {
        $('.searchcategory .description').hide();
    }
    else {
        $('#description_category').toggleClass('current');
    }
    if ($('#filename_visible').val() == "false") {
        $('.searchcategory .filename').hide();
    }
    else {
        $('#filename_category').toggleClass('current');
    }
    if ($('#tags_visible').val() == "false") {
        $('.searchcategory .tags').hide();
    }
    else {
        $('#tags_category').toggleClass('current');
    }
    if ($('#type_visible').val() == "false") {
        $('.searchcategory .type').hide();
    }
    else {
        $('#type_category').toggleClass('current');
    }
    if ($('#uploader_visible').val() == "false") {
        $('.searchcategory .uploader').hide();
    }
    else {
        $('#uploader').toggleClass('current');
    }
    if ($('#upload_date_visible').val() == "false") {
        $('.searchcategory .upload_date').hide();
    }
    else {
        $('#upload_date').toggleClass('current');
    }

    $('#date').click(function (event) {
        $('.searchcategory .date').slideToggle();
        $(this).toggleClass('current');
    });

    $('#time').click(function (event) {
        $('.searchcategory .time').slideToggle();
        $(this).toggleClass('current');
    });

    $('#facility').click(function (event) {
        $('.searchcategory .facility').slideToggle();
        $(this).toggleClass('current');
    });

    $('#variable').click(function (event) {
        $('.searchcategory .variable').slideToggle();
        $(this).toggleClass('current');
    });

    $('#filename_category').click(function (event) {
        $('.searchcategory .filename').slideToggle();
        $(this).toggleClass('current');
    });

    $('#description_category').click(function (event) {
        $('.searchcategory .description').slideToggle();
        $(this).toggleClass('current');
    });

    $('#type_category').click(function (event) {
        $('.searchcategory .type').slideToggle();
        $(this).toggleClass('current');
    });

    $('#tags_category').click(function (event) {
        $('.searchcategory .tags').slideToggle();
        $(this).toggleClass('current');
    });

    $('#uploader').click(function (event) {
        $('.searchcategory .uploader').slideToggle();
        $(this).toggleClass('current');
    });

    $('#upload_date').click(function (event) {
        $('.searchcategory .upload_date').slideToggle();
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