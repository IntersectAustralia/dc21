Then /^I should not see link "([^\"]*)" in "([^\"]*)"$/ do |text, scope|
  with_scope(scope) do
    page.should_not have_link(text)
  end
end

Then /^I should see link "([^\"]*)" in "([^\"]*)"$/ do |text, scope|
  with_scope(scope) do
    page.should have_link(text)
  end
end

Then /^I should not see the pagination area$/ do
  page.should have_no_xpath("div[@class='pagination']")
end

Given /^We paginate more than (\d+) (.*)$/ do |number, model_name|
  model = model_name.singularize.gsub(/[^A-z]+/, '_').camelize.constantize
  @overwritten_paginations ||= {}
  @overwritten_paginations[model] ||= model.per_page # Remember only the initial value, even if called multiple times
  model.per_page = number.to_i
end

After do
  if @overwritten_paginations
    @overwritten_paginations.each do |model, per_page|
      model.per_page = per_page
    end
  end
end