module CategoriesHelper
  def selectable_grouped_categories
    options = []
    JobOffer::CATEGORIES.overcategories_names.each do |parent|
      # Add visual indicator to parent categories
      options << ["▼ #{parent}", parent, {class: "parent-option-joboffers"}]
      JobOffer::CATEGORIES.categories_for(parent).each do |child|
        # Add indentation and visual indicator to child categories
        options << ["    ├ #{child}", child, {class: "child-option-joboffers"}]
      end
    end
    options
  end
end
