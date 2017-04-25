# frozen_string_literal: true

require 'minitest/autorun'
require 'phut/link'

module Phut
  class LinkTest < Minitest::Test
    def test_create
      Link.create :name1, :name2
      assert_equal 1, Link.all.size
    end

    def teardown
      `ifconfig -a`.split("\n").each do |each|
        next unless /^(#{Veth::PREFIX}\S+)/ =~ each
        system "sudo ip link delete #{Regexp.last_match(1)} 2>/dev/null"
      end
    end
  end
end
