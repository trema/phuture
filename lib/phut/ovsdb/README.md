
Primitive OVSDB client implementation
===

Supports [RFC7047](https://tools.ietf.org/html/rfc7047).

## Examples

### Transaction

* Create Bridge

```ruby
require 'active_flow'

class OVSDBTest
  extend ActiveFlow::OVSDB::Transact

  def self.create_bridge(name, ofc_target, bridge_options = {})
    client = ActiveFlow::OVSDB::Client.new('localhost', 6632)
    ovs_rows_query = select('Open_vSwitch', [], [:_uuid, :bridges])
    ovs_row = client.transact(1, 'Open_vSwitch', [ovs_rows_query]).first[:rows].first
    ovs_bridges = ovs_row[:bridges]
    new_ovs_bridges = case ovs_bridges.include?('set')
                      when true
                        ovs_bridges_content = ovs_bridges[1]
                        case ovs_bridges_content.empty?
                        when true
                          ['named-uuid', "bridge_br_#{name}"]
                        else
                          ['set', ovs_bridges_content << ['named-uuid', "bridge_br_#{name}"]]
                        end
                      else
                        ovs_bridges_content = ovs_bridges[1]
                        ['set', [ovs_bridges_content] << ['named-uuid', "bridge_br_#{name}"]]
                      end
    ovs_uuid = ovs_row[:_uuid]
    interface = { name: "br-#{name}", type: "internal" }
    port = { name: "br-#{name}", interfaces: ['named-uuid', "interface_br_#{name}"] }
    controller = { target: ofc_target }
    bridge = { name: "br-#{name}", ports: ['named-uuid', "port_br_#{name}"], controller: ['named-uuid', "ofc_br_#{name}"], protocols: 'OpenFlow10' }
    transactions = [
      insert('Interface', interface, "interface_br_#{name}"),
      insert('Port', port, "port_br_#{name}"),
      insert('Controller', controller, "ofc_br_#{name}"),
      insert('Bridge', bridge, "bridge_br_#{name}"),
      update('Open_vSwitch', [[:_uuid, :==, ovs_uuid]], { bridges: new_ovs_bridges }),
      mutate('Open_vSwitch', [[:_uuid, :==, ovs_uuid]], [[:next_cfg, '+=', 1]])
    ]
    client.transact(1, 'Open_vSwitch', transactions)
    transactions = [
      update('Bridge', [[:name, :==, "br-#{name}"]], { other_config: [:map, bridge_options.to_a] }),
      mutate('Open_vSwitch', [[:_uuid, :==, ovs_uuid]], [[:next_cfg, '+=', 1]])
    ]
    client.transact(1, 'Open_vSwitch', transactions)
  end

  def self.connect_with_patch(br1, br2)
    patch_br1 = "patch-#{br1}"
    patch_br2 = "patch-#{br2}"
    client = ActiveFlow::OVSDB::Client.new('localhost', 6632)
    ovs_rows_query = select('Open_vSwitch', [], [:_uuid])
    ovs_row = client.transact(1, 'Open_vSwitch', [ovs_rows_query]).first[:rows].first
    ovs_uuid = ovs_row[:_uuid]
    selects = [
      select('Bridge', [[:name, :==, br1]], [:ports]),
      select('Bridge', [[:name, :==, br2]], [:ports])
    ]
    br1_ports, br2_ports = client.transact(1, 'Open_vSwitch', selects)
    new_br1_ports = br1_ports.map do |_, item|
      ports = item[0][:ports].include?('set') ? item[0][:ports][1] : [item[0][:ports]]
      [:set, ports << ['named-uuid', :patch_br1]]
    end.first
    new_br2_ports = br2_ports.map do |_, item|
      ports = item[0][:ports].include?('set') ? item[0][:ports][1] : [item[0][:ports]]
      [:set, ports << ['named-uuid', :patch_br2]]
    end.first

    patch_br1_port = {name: patch_br1, interfaces: ['named-uuid', :patch_br1_iface]}
    patch_br2_port = {name: patch_br2, interfaces: ['named-uuid', :patch_br2_iface]}

    patch_br1_iface = {name: patch_br1, type: :patch, options: [:map, {peer: patch_br2}.to_a]}
    patch_br2_iface = {name: patch_br2, type: :patch, options: [:map, {peer: patch_br1}.to_a]}

    transactions = [
      insert('Interface', patch_br1_iface, :patch_br1_iface),
      insert('Interface', patch_br2_iface, :patch_br2_iface),
      insert('Port', patch_br1_port, :patch_br1),
      insert('Port', patch_br2_port, :patch_br2),
      update('Bridge', [[:name, :==, br1]], { ports: new_br1_ports }),
      update('Bridge', [[:name, :==, br2]], { ports: new_br2_ports }),
      mutate('Open_vSwitch', [[:_uuid, :==, ovs_uuid]], [[:next_cfg, '+=', 1]])
    ]
    client.transact(1, 'Open_vSwitch', transactions)
  end
end

# OVSDBTest.create_bridge('def', 'tcp:127.0.0.1:6653', 'datapath-id' => '0000000000000def')
# OVSDBTest.connect_with_patch('nts0xabc', 'br-def')
```
