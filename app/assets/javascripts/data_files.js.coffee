jQuery ->
  $('.variable_children').hide()
  $('.facility_children').hide()
  $('.type_children').hide()

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

  #select all on parent click
  $('input.facility_parent').click ->
    cb = $(this)
    children = cb.closest('div.facility_group').find('input.experiment')
    if cb.is(':checked')
      children.each ->
        $(this).prop("checked", true)
    else
      children.each ->
        $(this).prop("checked", false)

  #select all on parent click
  $('input.type_parent').click ->
    cb = $(this)
    children = cb.closest('div.type_group').find('input.publish')
    if !cb.is(':checked')
      children.each ->
        $(this).prop("checked", false)

  # child click - experiment
  $('input.experiment').click ->
    cb = $(this)
    parent = cb.closest('div.facility_group').find('input.facility_parent').first()
    if cb.is(':checked')
      child_count = cb.closest('div.facility_group').find('input.experiment').length
      checked_child_count = cb.closest('div.facility_group').find('input.experiment:checked').length
      if child_count == checked_child_count
        parent.prop("checked", true)
    else
      parent.prop("checked", false)

  # child click  - publish yes/no
  $('input.publish').click ->
    cb = $(this)
    parent = cb.closest('div.type_group').find('input.type_parent').first()
    if cb.is(':checked')
      checked_children = cb.closest('div.type_group').find('input.publish:checked')
      if checked_children.length > 0
        parent.prop("checked", true)
      #uncheck other options
      checked_children.each ->
        $(this).prop("checked", false)
      cb.prop("checked", true)

  # child click  - publish date
  $('input.publish_date').click ->
    cb = $(this)
    parent = cb.closest('div.type_group').find('input.type_parent').first()
    parent.prop("checked", true)


  # expand and hide
  $('.expand_facility').click ->
    children_div = $(this).closest('div.facility_group').find('.facility_children').first()
    children_div.slideToggle('fast')
    if $(this).text() == "+"
      $(this).text("-")
    else
      $(this).text("+")
    false

  # expand and hide
  $('.expand_type').click ->
    children_div = $(this).closest('div.type_group').find('.type_children').first()
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

    next = $("#" + next_id)

    if next.length == 0
      html = "" +
      "<label class='control-label' for='" + next_id + "'>Select file(s)</label>\n" +
      "<div class='controls'>\n" +
      "  <input id='" + next_id + "' multiple='multiple' name='files[]' type='file'>\n" +
      "</div>"

      $("#files_input").append(html)

  $('[id^="file_"][id$="_time"]').live 'change', ->
    id_val = parseInt($(this).attr('id').match(/file_([0-9]+).*/).pop())
    time_type = $(this).attr('id').match(/file_([0-9]+)_(start|end)_time/).pop()
    selector_to_toggle = "#file_" + id_val + "_" + time_type + "_container"
    if $(this).val() == ""
      $(selector_to_toggle).hide()
    else
      $(selector_to_toggle).show()

