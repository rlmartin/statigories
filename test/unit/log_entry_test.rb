require 'test_helper'

class LogEntryTest < ActiveSupport::TestCase
  def test_associations
    le = LogEntry.find_by_id(log_entries(:log_one).id)
    assert_equal le.user, User.find_by_id(users(:ryan))
    assert_equal le.items.count, 2
    assert_not_nil le.items.find_by_id(log_entry_items(:item_one).id)
  end

  def test_should_set_tags
    le = LogEntry.find_by_id(log_entries(:log_one).id)
    le.save
    le.reload
    assert_equal le.tags.count, 1
    assert_equal le.tags[0].name, 'running'
    le.label = 'biking workout'
    le.save
    le.reload
    assert_equal le.tags.count, 2
    assert_equal le.tags[0].name, 'biking'
  end

  def test_should_not_allow_other_tags
    le = LogEntry.find_by_id(log_entries(:log_one).id)
    lbl = le.label
    le.tag_list = 'tag1, tag2'
    le.save
    le.reload
    assert_equal lbl.downcase, le.tag_list.to_s
    assert_not_equal 'tag1, tag2', le.tag_list.to_s
  end

  def test_valid_access_levels
    u = User.find_by_id(users(:ryan))
    assert_not_nil u
    le = u.log_entries.create(:access_level => 1)
    assert_not_nil le.id
    le = u.log_entries.create(:access_level => 0)
    assert_not_nil le.id
    le = u.log_entries.create(:access_level => -1)
    assert_not_nil le.id
    le = u.log_entries.create
    assert_not_nil le.id
    # default should be 1
    assert_equal le.access_level, 1
  end

  def test_invalid_access_levels
    u = User.find_by_id(users(:ryan))
    assert_not_nil u
    le = u.log_entries.create(:access_level => 2)
    assert_not_nil le.id
    assert_equal le.access_level, 1
    le = u.log_entries.create(:access_level => -2)
    assert_not_nil le.id
    assert_equal le.access_level, 1
    le = u.log_entries.create(:access_level => nil)
    assert_not_nil le.id
    assert_equal le.access_level, 1
  end

  def test_date_set
    d = Time.now
    u = User.find_by_id(users(:ryan))
    assert_not_nil u
    le = u.log_entries.create(:date => d)
    assert_not_nil le.id
    assert_equal le.date, d
  end

  def test_date_automatically_set
    d = Time.now
    u = User.find_by_id(users(:ryan))
    assert_not_nil u
    le = u.log_entries.create
    assert_not_nil le.id
    assert_equal le.date.to_s, d.to_s
  end

  def test_index_set
    u = User.find_by_id(users(:ryan))
    assert_not_nil u
    previous = u.log_entries.find(:first, :order => '`index` DESC')
    le = u.log_entries.create
    assert_not_nil le.id
    assert_not_nil le.index
    assert_equal le.index, (previous == nil ? 1 : previous.index + 1)
    previous = u.log_entries.find(:first, :order => '`index` DESC')
    assert_not_nil previous
    le = u.log_entries.create
    assert_not_nil le.id
    assert_not_nil le.index
    assert_equal le.index, previous.index + 1
  end

  def test_index_overridden
    u = User.find_by_id(users(:ryan))
    assert_not_nil u
    previous = u.log_entries.find(:first, :order => '`index` DESC')
    le = u.log_entries.create
    assert_not_nil le.id
    assert_not_nil le.index
    assert_equal le.index, (previous == nil ? 1 : previous.index + 1)
    le.index = 100
    le.save
    le.reload
    assert_not_nil le.index
    assert_equal le.index, (previous == nil ? 1 : previous.index + 1)
    le = u.log_entries.create(:index => 100)
    assert_not_nil le.id
    assert_not_nil le.index
    assert_equal le.index, (previous == nil ? 1 : previous.index + 2)
    le = u.log_entries.new
    le.index = 100
    le.save
    assert_not_nil le.id
    le.reload
    assert_not_nil le.index
    assert_equal le.index, (previous == nil ? 1 : previous.index + 3)
  end

  def test_should_not_save_without_user
    le = LogEntry.new
    assert !le.save
    assert_nil le.user_id
    assert_nil le.id
    assert !le.errors[:user_id].empty?
    assert_equal le.errors.count, 1
  end

  def test_should_delete_subitems_on_destroy
    u = User.find_by_id(users(:ryan))
    assert_not_nil u
    le = u.log_entries.create(:access_level => 1)
    assert_not_nil le.id
    i = le.items.create(:value => '1')
    assert_not_nil i.id
    assert_not_nil LogEntryItem.find_by_id(i.id)
    assert le.destroy
    assert_nil LogEntryItem.find_by_id(i.id)
  end

  def test_should_find_when_tagged
    tagged = LogEntry.tagged_with('biking')
    tag_count = tagged.count
    le = LogEntry.find_by_id(log_entries(:log_one))
    assert_nil tagged.index(le)
    le.label = 'biking'
    assert le.save
    le.tags.reload
    assert_equal le.tags.count, 1
    tagged = LogEntry.tagged_with('biking')
    assert_equal tagged.count, tag_count + 1
    assert_not_nil tagged.index(le)
  end

  def test_should_find_when_tagged_with_multiple
    le1 = LogEntry.find_by_id(log_entries(:log_one))
    le1.label = 'running miles'
    assert le1.save
    le2 = LogEntry.find_by_id(log_entries(:log_two))
    le2.label = 'biking miles'
    assert le2.save
    tagged = LogEntry.tagged_with('miles')
    assert_not_nil tagged.index(le1)
    assert_not_nil tagged.index(le2)
    tagged = LogEntry.tagged_with('running, miles')
    assert_not_nil tagged.index(le1)
    assert_nil tagged.index(le2)
  end
end
