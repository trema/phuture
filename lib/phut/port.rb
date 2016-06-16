module Phut
  # OpenvSwitch Port class
  class Port

    attr_reader :device
    attr_reader :number

    def initialize(device:, number:)
      @device = device
      @number = number
    end

    def inspect
      "#<Port device: \"#{device}\", number: #{number}>"
    end

    def to_s
      "port (device = #{device}, number = #{number})"
    end
  end
end
