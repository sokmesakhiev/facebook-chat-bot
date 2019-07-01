module Questions::HtmlElementerizableConcern
  extend ActiveSupport::Concern

  included do
    def html_tag
      "
        #{label_tag}
        #{input_tag}
      "
    end

    def card_tag
      "
        <div class='card'>
          <img class='card-img-top' src='#{FileUtil.image_url(bot, media_image)}' alt='Card image cap'>
          <div class='card-body carousel-title'>
            <h5 class='card-title'>#{label}</h5>
            <p class='card-text'>#{description}</p>
          </div>
          <ul class='list-group list-group-flush card-list'>
            #{options_tag(:list)}
          </ul>
        </div>
      "
    end

    def label_tag
      "
        <div class='field-name'>
          #{"<span class='text-danger'> * </span>" if required}<label for=#{name}>#{label}</label>
        </div>
      "
    end

    def input_tag
      "<input id='#{name}' name='#{name}' type=#{kind} class='form-control' />"
    end

    def bullet_tag
      label.split("\n").map do |labelRow|
        "
          <div class='#{kind}'>
            <label>#{labelRow}</label>
          </div>
        "
      end.join('')
    end

    def list_tag choice = nil
      return '' if choice.nil?

      "
        <li class='list-group-item'>#{choice.label}</li>
      "
    end

    def select_one_tag choice = nil
      return '' if choice.nil?

      "
        <div class='#{kind}'>
          <label><input type='#{kind}' name='#{choice.name}' value='#{choice.name}'>#{choice.label}</label>
        </div>
      "
    end

    def options_tag type = :select_one
      options = choices.map do |choice|
        send("#{type}_tag", choice)
      end.join('')
    end
  end
end
