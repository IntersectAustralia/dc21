class PagesController < ApplicationController

 def home
   set_tab :home
   set_tab :dashboard, :adminnavigation
 end

 def about
   set_tab :about
 end

 def explore
   set_tab :home
   set_tab :explore, :adminnavigation
 end

end
