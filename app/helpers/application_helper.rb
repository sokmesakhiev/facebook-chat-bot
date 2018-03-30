module ApplicationHelper
  def css_id_name
    prefix = params['controller'].downcase.split('/').join('-')
    subfix = params['action']

    "#{prefix}-#{subfix}"
  end

  def current_class?(test_path)
    return 'active' if request.path == test_path
    ''
  end
end
