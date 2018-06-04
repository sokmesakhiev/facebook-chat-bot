class Parsers::MessageParser
  ### media ###
  # "sender"=>{"id"=> "123456"},
  # "recipient"=>{"id"=>"123456"},
  # "timestamp"=>"20180529 12:12:12"
  # "message"=>{
  #   "mid"=>"mid.$cAAUFvU--Yxhp1yD0wljpducn5q-G", 
  #   "seq"=>570026, 
  #   "attachments"=>[{
  #     "type"=>"image/audio", 
  #     "payload"=>{"url"=>"https://cdn.fbsbx.com/v/t59.3654-21/33417656_2255962251095772_5933083726958297088_n.mp4/audioclip-1527496025000-3136.mp4?_nc_cat=0&oh=b1df6937b4a8a3d0ddc46a63e138942d&oe=5B0D6C37"}
  #   }]
  # }

  ### text ###
  # "sender"=>{"id"=> "123456"},
  # "recipient"=>{"id"=>"123456"},
  # "timestamp"=>"20180529 12:12:12"
  # "message"=>{
  #   "mid"=>"mid.$cAAUFvU--Yxhp1yD0wljpducn5q-G", 
  #   "seq"=>570026, 
  #   "text"=>"Hello world!"
  # }

  ### postback GET STARTED BUTTON to establish user session ###
  # "sender"=>{"id"=> "123456"},
  # "recipient"=>{"id"=>"123456"},
  # "timestamp"=>"20180529 12:12:12"
  # "postback"=>{
  #   "mid"=>"mid.$cAAUFvU--Yxhp1yD0wljpducn5q-G", 
  #   "seq"=>570026, 
  #   "payload"=>"first_welcome"
  # }
  def self.parse messaging_event = {}
    if messaging_event['postback']
      ::Messages::PostbackMessage.new(messaging_event)
    elsif messaging_event['message']
      messaging_event['message']['attachments'].present? ? ::Messages::MediaMessage.new(messaging_event) : ::Messages::TextMessage.new(messaging_event)
    else
      raise "Unknown messaging event: #{messaging_event}"
    end
  end
end
