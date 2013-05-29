$(function () {
  if ($("#mint-server-feedback").length) {
    $("#mint-server-feedback").hide();

    $('#second_level').hide();
    $('#third_level').hide();

    getTopLevel();
  }

  $('select#for_code_select_1').change(function (e) {
    var new_value = $(this).val();
    if (new_value != "") {
      getSecondLevel($(this).val());
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
      getThirdLevel($(this).val());
    }
    else {
      $('select#for_code_select_3').html("<option value=''>Please select</option>");
      $('#third_level').hide();
    }
  });

  // AJAX calls to get FOR codes
  function getTopLevel() {
    $.ajax({
      url: "/for_codes/top_level",
      dataType: "json",
      async: false,
      success: function(result) {
        $('select#for_code_select_1').html("<option value=''>Please select</option>");
        $.each(result, function (item, value) {
          $("<option value='" + value[1] + "'>" + value[0] + "</option>").appendTo("select#for_code_select_1");
        });
        handleError(false);
      },
      error: function() {
        handleError(true);
      }
    })
  }

  function getSecondLevel(topLevelData) {
    $.ajax({
      url: "/for_codes/second_level",
      dataType: "json",
      data: {top_level: topLevelData},
      async: false,
      success: function(result) {
        $('select#for_code_select_2').html("<option value=''>Please select</option>");
        $.each(result, function (item, value) {
          $("<option value='" + value[1] + "'>" + value[0] + "</option>").appendTo("select#for_code_select_2");
        });
        $('#second_level').show();
        handleError(false);
      },
      error: function() {
        handleError(true);
      }
    });
  }

  function getThirdLevel(secondLevelData) {
    $.ajax({
      url: "/for_codes/third_level",
      dataType: "json",
      data: {second_level: secondLevelData},
      async: false,
      success: function(result) {
        $('select#for_code_select_3').html("<option value=''>Please select</option>");
        $.each(result, function (item, value) {
          $("<option value='" + value[1] + "'>" + value[0] + "</option>").appendTo("select#for_code_select_3");
        });
        $('#third_level').show();
        handleError(false);
      },
      error: function() {
        handleError(true);
      }
    });
  }

  function handleError(disable) {
    if (disable) {
      $("#mint-server-feedback").show();
    } else {
      $("#mint-server-feedback").hide();
    }

    $("add_for_code_link").prop('disabled', disable);
  }

  $('#add_for_code_link').live('click', function () {
    if (mintServer.getStatus().isUp()) {
      addForCode();
      handleError(false);
    } else {
      handleError(true)
    }
    return false;
  });

  $('.delete_for_code').live('click', function () {
    if (mintServer.getStatus().isUp()) {
      handleError(false);
      $(this).parent().remove();
      return false;
    } else {
      handleError(true);
      return false;
    }
  });

  function addForCode() {
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
  }

  var mintServer = function mintServer() {
    var status = null;

    var getStatus = function() {
      $.ajax({
        url: "/for_codes/server_status",
        dataType: "text",
        async: false,
        success: function(data) {
          status = data;
        }
      });
      return this;
    };

    var isUp = function() {
      if (status == "200")
        return true;
      else if (status == "404")
        return false;
      else
        return false;
    };

    return {
      getStatus: getStatus,
      isUp: isUp
    }
  }();
});
