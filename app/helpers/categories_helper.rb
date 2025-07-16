module CategoriesHelper
  def selectable_grouped_categories
    options = []
    JobOffer::CATEGORIES.overcategories_names.each do |parent|
      options << [parent, parent]
      JobOffer::CATEGORIES.categories_for(parent).each do |child|
        options << ["* #{child}", child]
      end
    end
    options
  end
end