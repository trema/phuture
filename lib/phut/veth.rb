# frozen_string_literal: true

require 'ipaddr'
require 'phut/shell_runner'

module Phut
  # Virtual eth device
  class Veth
    PREFIX = 'L'

    extend ShellRunner

    def self.all
      Netns.all.map(&:device).compact +
        sh('ip link show').split("\n").map do |each|
          match = /^\d+: #{PREFIX}(\d+)_([^:]*?)[@:]/.match(each)
          if match
            if /^\h{8}$/.match?(match[2])
              new(name: IPAddr.new(match[2].hex, Socket::AF_INET), link_id: match[1].to_i)
            else
              new(name: match[2], link_id: match[1].to_i)
            end
          else
            nil
          end
        end.compact
    end

    attr_reader :link_id

    def initialize(name:, link_id:)
      @name = name
      @link_id = link_id
    end

    def name
      @name.to_s
    end

    def device
      if @name.is_a?(IPAddr)
        hex = format('%x', @name.to_i)
        "#{PREFIX}#{@link_id}_#{hex}"
      else
        "#{PREFIX}#{@link_id}_#{@name}"
      end
    end

    def ==(other)
      name == other.name && link_id == other.link_id
    end

    def <=>(other)
      device <=> other.device
    end
  end
end
