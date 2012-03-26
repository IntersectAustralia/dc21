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
