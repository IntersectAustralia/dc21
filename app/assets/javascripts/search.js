$(function () {
    var hidden_selects = true;

    // Date
    if ( $('#from_date').val() || $('#to_date').val() ) {
        $('#date').toggleClass('current');
    }
    else {
        $('.searchcategory .date').hide();
    }

    $('.searchcategory .time').hide();

    // Filename
    if ($.trim($('#filename').val()).length > 0 ) {
        $('#filename_category').toggleClass('current');
    }
    else {
        $('.searchcategory .filename').hide();
    }

    // Description
    if ($.trim($('#description').val()).length > 0 ) {
        $('#description_category').toggleClass('current');
    }
    else {
        $('.searchcategory .description').hide();
    }

    // Type
    if ( $('.searchcategory .type input[type="checkbox"][checked]').length > 0 ) {
        $('#type_category').toggleClass('current');
    }
    else {
        $('.searchcategory .type').hide();
    }

    // Type children
    $('.type_group').each(function(index) {
        if ( $(this).find('input[type="checkbox"][checked]').length == 0 ) {
            $('.type_children', this).hide();
            $('.expand_type', this).text("+");
        }
        else {
            $('.expand_type', this).text("-");
        }
    });

    // Tags
    if ( $('.searchcategory .tags input[type="checkbox"][checked]').length > 0 ) {
        $('#tags_category').toggleClass('current');
    }
    else {
        $('.searchcategory .tags').hide();
    }

    // Facility
    if ( $('.searchcategory .facility input[type="checkbox"][checked]').length > 0 ) {
        $('#facility').toggleClass('current');
    }
    else {
        $('.searchcategory .facility').hide();
    }

    // Facility children
    $('.facility_group').each(function(index) {
        if ( $(this).find('input[type="checkbox"][checked]').length == 0 ) {
            $('.facility_children', this).hide();
            $('.expand_facility', this).text("+");
        }
        else {
            $('.expand_facility', this).text("-");
        }
    });

    // Columns
    if ( $('.searchcategory .variable input[type="checkbox"][checked]').length > 0 ) {
        $('#variable').toggleClass('current');
    }
    else {
        $('.searchcategory .variable').hide();
    }

    // Column children
    $('.variable_group').each(function(index) {
        if ( $(this).find('input[type="checkbox"][checked]').length == 0 ) {
            $('.variable_children', this).hide();
            $('.expand_variable', this).text("+");
        }
        else {
            $('.expand_variable', this).text("-");
        }
    });

    // Added By
    if ( $('.searchcategory .uploader option[selected]').length > 0 ) {
        $('#uploader').toggleClass('current');
    }
    else {
        $('.searchcategory .uploader').hide();
    }

    // Date Added
    if ( $('#upload_from_date').val() || $('#upload_to_date').val() ) {
        $('#upload_date').toggleClass('current');
    }
    else {
        $('.searchcategory .upload_date').hide();
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
