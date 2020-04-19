require "socket"
require "yaml"
require "jfl_alarmes/version"
require "jfl_alarmes/jfl_event"

module JflAlarmes
  class JflMonitor
    attr_accessor :server
    attr_accessor :events
    attr_accessor :thread
    
    # inicia o monitoramento
    def run(socket_port)

      if @server.nil?
        @close = false
        # fica escutando a porta 2034
        @server = TCPServer.new socket_port
        # lista de eventos
        @events = Array.new
    
        @thread = Thread.new{
          socket = @server.accept
          handle_connection(socket)
        }
      else
        puts "Thread já rodando use o comando force_close() para fechar a thread"
      end
    end
    
    def force_close()
      @close = true
      Thread.kill(@thread)
      @server.close
    end

    private
    
    attr_accessor :close
    
    def handle_connection(socket)
      loop do
        msg = socket.recvfrom(30) # recebe a mensage - 30 bytes - do cliente

        # Procedimento de conexão
        if(msg[0][0] == '!')
          @events << connection(msg[0].unpack('H*'))

          # Responde a conexão
          resp = "+"
          socket.write("+")
        end

        # Alteração de status
        if(msg[0][0] == '$')
          @events << contact_id(msg[0])
          keep_alive(socket)
        end

        # Keep alive
        if(msg[0][0] == '@')
          @events << keep_alive(socket)
        end
        
        if(@close)
          socket.close
          break
        end
      end
    end

    def keep_alive(socket)
      # Keep Alive
      resp = "@1"
      socket.write(resp)
      
      event = JflEvent.new
      event.type = "@"
      event.status = "Enviado"
    end

    def connection(content)
      event = JflEvent.new

      #0.        10.       20.       30.       40.       50.       
      #012345678901234567890123456789012345678901234567890123456789
      #21ffffffffffffffffffffffffffffff5410ec8630590390039053a10608
      event.type = "!"
      event.imei = content[2..31]
      event.mac = content[32..43]
      event.conta_part_a = content[44..47]
      event.conta_part_b = content[48..51]
      event.versao = content[52..53]
      event.modelo = content[54..55]
      event.oper = content[56..57]
      event.status = content[58..59]

      event
    end

    def contact_id(content)
        #0.        10.      
        #0123456789012345678
        #$0390160201000A\x10

        event = JflEvent.new
        event.type = "$"
        event.account = content[1..4]
        event.event = content[5..8]
        event.partition = content[9..10]
        event.user_zone = content[11..13]
        event.count = content[14]
        event.status = content[15..]

        event
    end
  end
end