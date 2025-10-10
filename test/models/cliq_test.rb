require "test_helper"

class CliqTest < ActiveSupport::TestCase
  test "cannot create more than #{Cliq::MAX_CHILD_CLIQS} child cliqs under same parent" do
    parent = cliqs(:root_cliq)

    existing = parent.child_cliqs.count
    remaining = Cliq::MAX_CHILD_CLIQS - existing
    remaining.times do |n|
      parent.child_cliqs.create!(name: "Child #{existing + n}")
    end

    assert_equal Cliq::MAX_CHILD_CLIQS, parent.child_cliqs.count
    assert_equal Cliq::MAX_CHILD_CLIQS, Cliq.where(parent_cliq_id: parent.id).count

    extra = parent.child_cliqs.build(name: "Overflow child")
    assert_equal parent.id, extra.parent_cliq_id
    assert_not_nil extra.parent_cliq
    extra.valid?
    assert_equal Cliq::MAX_CHILD_CLIQS, Cliq.where(parent_cliq_id: parent.id).count
    assert_includes extra.errors[:base], "This cliq already has the maximum number of child cliqs (#{Cliq::MAX_CHILD_CLIQS})."
  end

  test "cannot create child beyond maximum hierarchy depth" do
    parent = cliqs(:root_cliq)
    (Cliq::MAX_TREE_LEVELS - parent.level_from_root).times do |n|
      parent = Cliq.create!(name: "Depth #{n}", parent_cliq: parent)
    end

    assert_not parent.can_add_child?, "Expected parent at max depth to disallow further children"

    child = parent.child_cliqs.build(name: "Too deep")
    child.valid?
    assert_includes child.errors[:base], "This cliq is already at the deepest level allowed."
  end
end
