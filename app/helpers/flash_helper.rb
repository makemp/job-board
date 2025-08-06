module FlashHelper
  def flash_class(type)
    case type.to_sym
    when :notice
      "bg-green-100 border border-green-400 text-green-800"
    when :alert, :error
      "bg-red-100 border border-red-400 text-red-800"
    else
      "bg-gray-100 border border-gray-400 text-gray-800"
    end
  end
end
