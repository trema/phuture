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
    And "netmask" is "/24" in netns "host1"
    And "default_gateway" is "" in netns "host1"
    And a netns named "host2" launches
    And "netmask" is "/24" in netns "host2"
    And "default_gateway" is "" in netns "host2"

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
    And "netmask" is "/25" in netns "host1"
    And "default_gateway" is "192.168.8.1" in netns "host1"
    And a netns named "host2" launches
    And "netmask" is "/25" in netns "host2"
    And "default_gateway" is "192.168.8.1" in netns "host2"
