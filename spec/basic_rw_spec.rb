describe "basic reading and writing" do
  before do
    File.delete('socat.log') if File.file?('socat.log')

    Thread.new do
      system('socat -lf socat.log -d -d pty,raw,echo=0 pty,raw,echo=0')
    end

    @ptys = nil

    loop do
      if File.file? 'socat.log'
        @file = File.open('socat.log', "r")
        @fileread = @file.read
        unless @fileread.count("\n") < 3
          @ptys = @fileread.scan(/PTY is (.*)/)
          break
        end
      end
    end

    require 'rubyserial'
    @sp2 = Serial.new(@ptys[1][0])
    @sp2.write('hello')

                # small delay so it can write to the other port.
    sleep 5
  end

  it "should read and write" do
    EM.run do
      serial = EventMachine.open_serial(@ptys[0][0], 9600, 8)

      serial.on_data do |data|
        expect(data).to eq "hello\x00"
        EM.stop_event_loop
      end
    end
  end
end
