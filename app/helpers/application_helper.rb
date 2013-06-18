module ApplicationHelper
  def short_name name
    if name.length > Settings.MAX_LENGTH_NAME
      name = name.first(Settings.MAX_LENGTH_NAME) + "..."
    end
    name
  end
  
  def short_conversion name
    if name.length > Settings.MAX_CONVERSION_NAME
      name = name.first(Settings.MAX_CONVERSION_NAME) + "..."
    end
    name
  end
end
