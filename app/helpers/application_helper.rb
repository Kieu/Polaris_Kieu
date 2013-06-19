module ApplicationHelper
  def short_en_name name
    if name.length > Settings.MAX_EN_LENGTH_NAME
      name = name.first(Settings.MAX_EN_LENGTH_NAME) + "..."
    end
    name
  end
  
  def short_ja_name name
    if name.length > Settings.MAX_JA_LENGTH_NAME
      name = name.first(Settings.MAX_JA_LENGTH_NAME) + "..."
    end
    name
  end
end
