$(function () {
  $('#second_level').hide();
  $('#third_level').hide();

  $('select#for_code_select_1').change(function (e) {
    var new_value = $(this).val();
    if (new_value != "") {
      $.getJSON('/for_codes/second_level', {top_level:$(this).val()}, function (result) {
        $('select#for_code_select_2').html("<option value=''>Please select</option>");
        $.each(result, function (item, value) {
          $("<option value='" + value[1] + "'>" + value[0] + "</option>").appendTo("select#for_code_select_2");
        });
      });
      $('#second_level').show();
    }
    else {
      $('select#for_code_select_2').html("<option value=''>Please select</option>");
      $('#second_level').hide();
    }
    $('select#for_code_select_3').html("<option value=''>Please select</option>");
    $('#third_level').hide();
  });

  $('select#for_code_select_2').change(function (e) {
    var new_value = $(this).val();
    if (new_value != "") {
      $.getJSON('/for_codes/third_level', {second_level:$(this).val()}, function (result) {
        $('select#for_code_select_3').html("<option value=''>Please select</option>");
        $.each(result, function (item, value) {
          $("<option value='" + value[1] + "'>" + value[0] + "</option>").appendTo("select#for_code_select_3");
        });
      });
      $('#third_level').show();
    }
    else {
      $('select#for_code_select_3').html("<option value=''>Please select</option>");
      $('#third_level').hide();
    }
  });

  $('#add_for_code_link').live('click', function () {
    var for_code_1 = $('#for_code_select_1').val();
    var for_code_2 = $('#for_code_select_2').val();
    var for_code_3 = $('#for_code_select_3').val();
    var for_code = "";
    var for_code_text = "";
    if (for_code_3 != "") {
      for_code = for_code_3;
      for_code_text = $('#for_code_select_3 option:selected').text();
    }
    else if (for_code_2 != "") {
      for_code = for_code_2;
      for_code_text = $('#for_code_select_2 option:selected').text();
    }
    else if (for_code_1 != "") {
      for_code = for_code_1;
      for_code_text = $('#for_code_select_1 option:selected').text();
    }
    if (for_code != "") {
      var new_element = "<li>";
      var new_id = new Date().getTime();
      new_element += "<span>" + for_code_text + "</span>";
      new_element += "<input type='hidden' name='for_codes[" + new_id + "][url]', value='" + for_code + "'/>";
      new_element += "<input type='hidden' name='for_codes[" + new_id + "][name]', value='" + for_code_text + "'/>";
      new_element += "<a href='#' class='delete_for_code'> Delete</a>";
      new_element += "</li>";
      $('#for_codes_list').append(new_element);

      $('select#for_code_select_1').val("");
      $('select#for_code_select_2').html("<option value=''>Please select</option>");
      $('#second_level').hide();
      $('select#for_code_select_3').html("<option value=''>Please select</option>");
      $('#third_level').hide();
    }

    return false;
  });

  $('.delete_for_code').live('click', function () {
    $(this).parent().remove();
    return false;
  });
});
