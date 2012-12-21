module HtmlSelectorsHelpers
  # Maps a name to a selector. Used primarily by the
  #
  #   When /^(.+) within (.+)$/ do |step, scope|
  #
  # step definitions in web_steps.rb
  #
  def selector_for(locator)
    case locator

      when "the page"
        "html > body"

      when "the list of files to download"
        "#files_to_download"

      when "the api token display"
        "#api_token_display"

      when "the list of for codes"
        "#selected_for_codes"

      when "the file details area"
        "#file_details"

      when /^the file area for '(.*)'$/
        "#file_panel_#{DataFile.find_by_filename!($1).id}"

      when "the pagination area"
        "div.pagination"

      when "the exploredata table"
        "table#exploredata"

      when "the search box"
        "div.searchbox"
      # Add more mappings here.
      # Here is an example that pulls values out of the Regexp:
      #
      #  when /^the (notice|error|info) flash$/
      #    ".flash.#{$1}"

      # You can also return an array to use a different selector
      # type, like:
      #
      #  when /the header/
      #    [:xpath, "//header"]

      # This allows you to provide a quoted selector as the scope
      # for "within" steps as was previously the default for the
      # web steps:
      when /^"(.+)"$/
        $1

      else
        raise "Can't find mapping from \"#{locator}\" to a selector.\n" +
                  "Now, go and add a mapping in #{__FILE__}"
    end
  end
end

World(HtmlSelectorsHelpers)
