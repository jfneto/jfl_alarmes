module JflAlarmes
  class Event
    # Evento de conexão
    attr_accessor :type
    attr_accessor :imei
    attr_accessor :mac
    attr_accessor :conta_part_a
    attr_accessor :conta_part_a
    attr_accessor :versao
    attr_accessor :modelo
    attr_accessor :oper
    attr_accessor :status
  
    attr_accessor :account
    attr_accessor :event
    attr_accessor :partition
    attr_accessor :user_zone
    attr_accessor :count

    def initialize
    end
    
#    def get_event_description
#      contactIds = YAML.load_file('jfl_alarmes/contact_id.yml')
#      contactIds[@event]
#    end
  
  end
end