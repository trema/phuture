# frozen_string_literal: true
require 'phut/shell_runner'
require 'phut/ovsdb'
require 'phut/port'
require 'pio'

module Phut
  # ovs-vsctl wrapper
  class Vsctl
    extend ShellRunner
    include Phut::OVSDB::Transact
    extend Phut::OVSDB::Transact

    def self.list_br(prefix)
      sudo('ovs-vsctl list-br').split.each_with_object([]) do |each, list|
        next unless /^#{prefix}(\S+)/ =~ each
        dpid_str = sudo("ovs-vsctl get bridge #{each} datapath-id").delete('"')
        list << [Regexp.last_match(1), ('0x' + dpid_str).hex]
      end
    end

    include ShellRunner

    def initialize(name:, name_prefix:, dpid:, bridge:)
      @client = Phut::OVSDB::Client.new('localhost', 6632)
      @name = name
      @prefix = name_prefix
      @dpid = dpid
      @bridge = bridge
    end

    def tcp_port
      sudo("ovs-vsctl get-controller #{@bridge}").
        chomp.split(':').last.to_i
    end

    def add_bridge
      sudo "ovs-vsctl add-br #{@bridge}"
      sudo "/sbin/sysctl -w net.ipv6.conf.#{@bridge}.disable_ipv6=1 -q"
    end

    def del_bridge
      sudo "ovs-vsctl del-br #{@bridge}"
    end

    def set_manager
      sudo 'ovs-vsctl set-manager ptcp:6632'
    end

    def set_openflow_version_and_dpid
      sudo "ovs-vsctl set bridge #{@bridge} "\
           "protocols=#{Pio::OpenFlow.version} "\
           "other-config:datapath-id=#{dpid_zero_filled}"
    end

    def controller_tcp_port=(tcp_port)
      sudo "ovs-vsctl set-controller #{@bridge} "\
           "tcp:127.0.0.1:#{tcp_port} "\
           "-- set controller #{@bridge} connection-mode=out-of-band"
    end

    def set_fail_mode_secure
      sudo "ovs-vsctl set-fail-mode #{@bridge} secure"
    end

    def add_port(device)
      sudo "ovs-vsctl add-port #{@bridge} #{device}"
      nil
    end

    def add_numbered_port(port_number, device)
      add_port device
      sudo "ovs-vsctl set Interface #{device} "\
           "ofport_request=#{port_number}"
      nil
    end

    def bring_port_up(port_number)
      sh "sudo ovs-ofctl mod-port #{@bridge} #{port_number} up"
    end

    def bring_port_down(port_number)
      sh "sudo ovs-ofctl mod-port #{@bridge} #{port_number} down"
    end

    def ports
      br_query = [select('Bridge', [[:name, :==, @bridge]], [:ports])]
      br_ports = @client.transact(1, 'Open_vSwitch', br_query)
      if br_ports.first[:rows].first
        br_ports = br_ports.first[:rows].first[:ports]
        ports = if br_ports.include? "set"
                  br_ports[1]
                else
                  [br_ports]
                end
        port_query = ports.map do |port|
          select('Port', [[:_uuid, :==, port]], [:name])
        end
        iface_query = @client.transact(1, 'Open_vSwitch', port_query).map do |iface|
          select('Interface', [[:name, :==, iface[:rows].first[:name]]], [:ofport, :name])
        end
        @client.transact(1, 'Open_vSwitch', iface_query).map do |iface|
          device = iface[:rows].first[:name]
          number = iface[:rows].first[:ofport]
          Phut::Port.new(device: device, number: number)
        end
      else
        []
      end
    end

    private

    def dpid_zero_filled
      raise 'DPID is not set' unless @dpid
      hex = format('%x', @dpid)
      '0' * (16 - hex.length) + hex
    end
  end
end
