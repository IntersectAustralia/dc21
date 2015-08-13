class UpdateExperimentRightsUrIs < ActiveRecord::Migration

  def change
    update_experiment("http://creativecommons.org/licenses/by/3.0/au",       "http://creativecommons.org/licenses/by/4.0")
    update_experiment("http://creativecommons.org/licenses/by-sa/3.0/au",    "http://creativecommons.org/licenses/by-sa/4.0")
    update_experiment("http://creativecommons.org/licenses/by-nd/3.0/au",    "http://creativecommons.org/licenses/by-nd/4.0")
    update_experiment("http://creativecommons.org/licenses/by-nc/3.0/au",    "http://creativecommons.org/licenses/by-nc/4.0")
    update_experiment("http://creativecommons.org/licenses/by-nc-sa/3.0/au", "http://creativecommons.org/licenses/by-nc-sa/4.0")
    update_experiment("http://creativecommons.org/licenses/by-nc-nd/3.0/au", "http://creativecommons.org/licenses/by-nc-nd/4.0")
  end

  private

  def update_experiment(old_uri, new_uri)
    experiments = Experiment.where(:access_rights => old_uri)
    experiments.each do |experiment|
      experiment.update_attribute(:access_rights, new_uri)
    end
  end

end
