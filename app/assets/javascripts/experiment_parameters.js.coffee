jQuery ->
  subcategories = $('#parameter_sub_category_select').html()
  selected_subcategory = $('#parameter_sub_category_select option:selected').val()
  setup_subcategory_select(subcategories, selected_subcategory)

  $('#parameter_category_select').change ->
    setup_subcategory_select(subcategories, "")


setup_subcategory_select = (subcategories, selected_subcategory) ->
  category = $('#parameter_category_select :selected').text()
  if category == "Please select a category"
    $('#parameter_sub_category_select').html("<option value=''>Please select a category first</option>")
  else
    escaped_category = category.replace(/([ #;&,.+*~\':"!^$[\]()=>|\/@])/g, '\\$1')
    options = $(subcategories).filter("optgroup[label=#{escaped_category}]")
    count = $(options).find("option").length
    if count == 1
      $('#parameter_sub_category_select').html(options.html()) #don't include the prompt if there's only one
    else
      $('#parameter_sub_category_select').html("<option value=''>Please select a subcategory</option>" + options.html())
    $('#parameter_sub_category_select').val(selected_subcategory)
