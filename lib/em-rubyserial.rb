require "em-rubyserial/version"

require 'em/pure_ruby'
require 'rubyserial'

module EventMachine
  class Connection
    def on_data(&blk)
      @on_data = blk
    end

    def trigger_on_data(data)
      @on_data.call(data) if @on_data
    end

    def receive_data data
      trigger_on_data(data)
    end

    def associate_callback_target(sig)
      return(nil)
    end
  end
end

module EventMachine
  class << self
    def connect_serial(dev, baud, databits)
      SerialPort.open(dev, baud, databits).uuid
    end

    def open_serial(dev, baud, databits, handler=nil)
      klass = if(handler and handler.is_a?(Class))
        handler
      else
        Class.new(Connection) {handler and include handler}
      end
      uuid          = connect_serial(dev, baud, databits)
      connection    = klass.new uuid
      @conns[uuid]  = connection
      block_given? and yield connection
      connection
    end
  end

  class SerialPort < StreamObject
    def self.open(dev, baud, databits)
      serialport = ::Serial.new(dev, baud, databits)
      if RUBY_PLATFORM == "java"
        io = FFI::FileDescriptorIO.new(serialport.instance_variable_get(:@fd).to_i)
      else
        io = IO.new(serialport.instance_variable_get(:@fd), 'r+')
      end
      self.new(io)
    end

    def initialize(io)
      super
    end

    def eventable_read
      @last_activity = Reactor.instance.current_loop_time
      begin
        if io.respond_to?(:read_nonblock)
          10.times {
            data = io.read_nonblock(4096)
            EventMachine::event_callback uuid, ConnectionData, data
          }
        else
          data = io.sysread(4096)
          EventMachine::event_callback uuid, ConnectionData, data
        end
      rescue Errno::EAGAIN, Errno::EWOULDBLOCK, EOFError
        # no-op
      rescue Errno::ECONNRESET, Errno::ECONNREFUSED
        @close_scheduled = true
        EventMachine::event_callback uuid, ConnectionUnbound, nil
      end
    end

  end
end
