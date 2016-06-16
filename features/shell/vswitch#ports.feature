Feature: Vswitch#ports

  TODO: Vswitch#ports should return an array of Port object
  that contains its port number

  Background:
    Given I run `phut -v` interactively
    And I type "vswitch = Vswitch.create(dpid: 0xabc)"

  @sudo
  Scenario: Vswitch#ports #=> []
    When I type "vswitch.ports"
    And sleep 5
    Then the output should contain:
    """
    #<OpenStruct name="vsw_0xabc", ofport=65534>
    """

  @sudo
  Scenario: Vswitch#ports
    Given I type "link = Link.create('a', 'b')"
    And I type "vswitch.add_port link.device('a')"
    When I type "vswitch.ports"
    And sleep 5
    Then the output should contain:
    """
    #<OpenStruct name="L0_a", ofport=1>
    """

  @sudo
  Scenario: Vswitch#ports
    Given I type "link = Link.create('a', 'b')"
    And I type "vswitch.add_numbered_port 2, link.device('a')"
    When I type "vswitch.ports"
    And sleep 5
    Then the output should contain:
    """
    #<OpenStruct name="L0_a", ofport=2>
    """
