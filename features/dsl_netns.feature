Feature: The netns DSL directive.
  @sudo
  Scenario: phut run with "netns(alias) { ip ... }"
    Given a file named "network.conf" with:
    """
    netns('host1') {
      ip '192.168.8.6'
    }
    netns('host2') {
      ip '192.168.8.7'
    }
    link 'host1', 'host2'    
    """
    When I do phut run "network.conf"
    Then a netns named "host1" launches
    And the "netmask" of the netns "host1" should be "/24"
    And the "default_gateway" of the netns "host1" should be ""
    And a netns named "host2" launches
    And the "netmask" of the netns "host2" should be "/24"
    And the "default_gateway" of the netns "host2" should be ""

  @sudo
  Scenario: phut run with "netns(alias) { ip, netmask, route ... }"
    Given a file named "network.conf" with:
    """
    netns('host1') {
      ip '192.168.8.6'
      netmask '255.255.255.128'
      route net: '0.0.0.0/0', gateway: '192.168.8.1'
    }
    netns('host2') {
      ip '192.168.8.7'
      netmask '255.255.255.128'
      route net: '0.0.0.0/0', gateway: '192.168.8.1'
    }
    link 'host1', 'host2'    
    """
    When I do phut run "network.conf"
    Then a netns named "host1" launches
    And the "netmask" of the netns "host1" should be "/25"
    And the "default_gateway" of the netns "host1" should be "192.168.8.1"
    And a netns named "host2" launches
    And the "netmask" of the netns "host2" should be "/25"
    And the "default_gateway" of the netns "host2" should be "192.168.8.1"

  @sudo
  Scenario: phut run with "netns(alias) { ip, vlan }"
    Given a file named "network.conf" with:
    """
    netns('host1') {
      ip '192.168.8.6'
      vlan 10
    }
    netns('host2') {
      ip '192.168.8.7'
      vlan 20
    }
    link 'host1', 'host2'
    """
    When I do phut run "network.conf"
    Then a netns named "host1" launches
    And the "vlan" of the netns "host1" should be "10"
    And a netns named "host2" launches
    And the "vlan" of the netns "host2" should be "20"

  @sudo
  Scenario: phut run with "netns(alias) { ip, mac }"
    Given a file named "network.conf" with:
    """
    netns('host1') {
      ip '192.168.8.6'
      mac '00:53:00:00:00:01'
    }
    netns('host2') {
      ip '192.168.8.7'
      mac '00:53:00:00:00:02'
    }
    link 'host1', 'host2'
    """
    When I do phut run "network.conf"
    Then a netns named "host1" launches
    And the "mac" of the netns "host1" should be "00:53:00:00:00:01"
    And a netns named "host2" launches
    And the "mac" of the netns "host2" should be "00:53:00:00:00:02"
