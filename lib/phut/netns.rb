# frozen_string_literal: true
require 'active_support/core_ext/class/attribute_accessors'
require 'phut/null_logger'
require 'phut/shell_runner'

module Phut
  # `ip netns ...` command runner
  class Netns
    cattr_accessor(:all, instance_reader: false) { [] }

    def self.create(options, name, logger = NullLogger.new)
      new(options, name, logger).tap { |netns| all << netns }
    end

    def self.each(&block)
      all.each(&block)
    end

    include ShellRunner

    attr_reader :name
    attr_accessor :network_device

    def initialize(options, name, logger)
      @name = name
      @options = options
      @logger = logger
    end

    def run
      setup_netns
      setup_link
      setup_ip
    end

    def stop
      sh "sudo ip netns delete #{name}"
    end

    private

    def setup_netns
      sh "sudo ip netns add #{name}"
      sh "sudo ip link set dev #{network_device} netns #{name}"
    end

    def setup_link
      setup_vlan
      setup_mac_address
      sh "sudo ip netns exec #{name} ip link set lo up"
      sh "sudo ip netns exec #{name}"\
        " ip link set #{network_device}#{vlan_suffix} up"
    end

    def setup_vlan
      return unless vlan
      sh "sudo ip netns exec #{name}"\
        " ip link set #{network_device} up"
      sh "sudo ip netns exec #{name}"\
        " ip link add link #{network_device} name"\
        " #{network_device}#{vlan_suffix} type vlan id #{vlan}"
    end

    def setup_mac_address
      sh "sudo ip netns exec #{name}"\
        " ip link set #{network_device}#{vlan_suffix} address #{mac}" if mac
    end

    def setup_ip
      sh "sudo ip netns exec #{name} ip addr replace 127.0.0.1 dev lo"
      sh "sudo ip netns exec #{name}"\
        " ip addr replace #{ip}/#{netmask} dev #{network_device}#{vlan_suffix}"
      sh "sudo ip netns exec #{name}"\
        " ip route add #{net} via #{gateway}" if gateway
    end

    def vlan_suffix
      vlan ? ".#{vlan}" : ''
    end

    def method_missing(message, *_args)
      @options.__send__ :[], message
    end
  end
end
