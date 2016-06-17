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
      "#<Port number: #{number}, device: \"#{device}\">"
    end

    def to_s
      "port (number = #{number}, device = #{device})"
    end
  end
end
