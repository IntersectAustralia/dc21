jQuery ->
  $('.variable_children').hide()

  $('input.variable_parent').click ->
    cb = $(this)
    children = cb.closest('div.variable_group').find('input.variable_child')
    if cb.is(':checked')
      children.each ->
        $(this).prop("checked", true)
    else
      children.each ->
        $(this).prop("checked", false)

  $('input.variable_child').click ->
    cb = $(this)
    parent = cb.closest('div.variable_group').find('input.variable_parent').first()
    if cb.is(':checked')
      child_count = cb.closest('div.variable_group').find('input.variable_child').length
      checked_child_count = cb.closest('div.variable_group').find('input.variable_child:checked').length
      if child_count == checked_child_count
        parent.prop("checked", true)
    else
      parent.prop("checked", false)

  $('.expand_variable').click ->
    children_div = $(this).closest('div.variable_group').find('.variable_children').first()
    children_div.slideToggle('fast')
    if $(this).text() == "+"
      $(this).text("-")
    else
      $(this).text("+")
    false

  $(".sort_link").click (e) ->
    direction = $(this).data("direction")
    sort = $(this).data("sort")

    if $("#sort").val() != sort
      direction = "asc"

    $("input#direction").val(direction)
    $("input#sort").val(sort)
    $("form#search_form").submit()

    e.preventDefault()


  $('[id^="files_field_"]').live 'change', ->
    id_val = parseInt($(this).attr('id').match(/files_field_([0-9]+)/).pop())
    next_id = "files_field_" + (id_val + 1)

    next = $(next_id)

    if next.length == 0
      html = "" +
      "<label class='control-label' for='" + next_id + "'>Select file(s)</label>\n" +
      "<div class='controls'>\n" +
      "  <input id='" + next_id + "' multiple='multiple' name='files[]' type='file'>\n" +
      "</div>"

      $("#files_input").append(html)

  $('#publish_button').click (e) ->
    $("#search_form").attr("action", "/published_collections/new_from_search");
    $('#search_form').submit()
    e.preventDefault();
