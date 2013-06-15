module ApplicationHelper
  def short_name name
  	if name.nil?
  		name = ""
  	end

    if name.length > Settings.MAX_LENGTH_NAME
      name = name.first(Settings.MAX_LENGTH_NAME) + "..."
    end
    name
  end
end
