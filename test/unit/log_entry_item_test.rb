require 'test_helper'

class LogEntryItemTest < ActiveSupport::TestCase
  def test_associations
    i = LogEntryItem.find_by_id(log_entry_items(:item_one).id)
    assert_equal i.log_entry, LogEntry.find_by_id(log_entries(:log_one))
  end

  def test_should_not_save_without_log_entry
    i = LogEntryItem.new(:value => 1)
    assert !i.save
    assert_not_nil i.value
    assert_nil i.log_entry_id
    assert_nil i.id
    assert_not_nil i.errors.on(:log_entry_id)
    assert_equal i.errors.count, 1
  end

  def test_should_not_save_without_value
    le = LogEntry.find_by_id(log_entries(:log_one))
    i = le.items.new
    assert !i.save
    assert_not_nil i.log_entry_id
    assert_nil i.id
    assert_not_nil i.errors.on(:value)
    assert_equal i.errors.count, 1
  end

  def test_should_save
    le = LogEntry.find_by_id(log_entries(:log_one))
    item_count = le.items.count
    i = le.items.new
    i.value = 1
    assert i.save
    assert_not_nil i.log_entry_id
    assert_not_nil i.value
    assert_not_nil i.id
    assert_equal item_count + 1, le.items.count
  end

  def test_should_set_generated_values
    le = LogEntry.find_by_id(log_entries(:log_one))
    i = le.items.create(:value => '1')
    assert_not_nil i.id
    assert_equal i.value, '1'
    assert_equal i.value_bool, true
    assert_nil i.value_date
    assert_equal i.value_float, 1.0
    assert_equal i.value_int, 1
    assert_nil i.value_lat
    assert_nil i.value_lng

    i = le.items.create(:value => '0')
    assert_not_nil i.id
    assert_equal i.value, '0'
    assert_equal i.value_bool, false
    assert_nil i.value_date
    assert_equal i.value_float, 0.0
    assert_equal i.value_int, 0
    assert_nil i.value_lat
    assert_nil i.value_lng

    i = le.items.create(:value => '1.1')
    assert_not_nil i.id
    assert_equal i.value, '1.1'
    assert_nil i.value_bool
    assert_nil i.value_date
    assert_equal i.value_float, 1.1
    assert_nil i.value_int
    assert_nil i.value_lat
    assert_nil i.value_lng

    i = le.items.create(:value => '1/1/2010')
    assert_not_nil i.id
    assert_equal i.value, '1/1/2010'
    assert_nil i.value_bool
    assert_equal i.value_date, Date.new(2010, 1, 1)
    assert_nil i.value_float
    assert_nil i.value_int
    assert_nil i.value_lat
    assert_nil i.value_lng

    i = le.items.create(:value => '1/2/2010 10:08:01 PM')
    assert_not_nil i.id
    assert_equal i.value, '1/2/2010 10:08:01 PM'
    assert_nil i.value_bool
    assert_equal i.value_date, DateTime.new(2010, 1, 2, 22, 8, 1)
    assert_nil i.value_float
    assert_nil i.value_int
    assert_nil i.value_lat
    assert_nil i.value_lng

    i = le.items.create(:value => '(1.1, 2.1)')
    assert_not_nil i.id
    assert_equal i.value, '(1.1, 2.1)'
    assert_nil i.value_bool
    assert_nil i.value_date
    assert_nil i.value_float
    assert_nil i.value_int
    assert_equal i.value_lat, 1.1
    assert_equal i.value_lng, 2.1

    i = le.items.create(:value => '1.2, 2.2')
    assert_not_nil i.id
    assert_equal i.value, '1.2, 2.2'
    assert_nil i.value_bool
    assert_nil i.value_date
    assert_nil i.value_float
    assert_nil i.value_int
    assert_equal i.value_lat, 1.2
    assert_equal i.value_lng, 2.2

    i = le.items.create(:value => '{1.3, 2.3}')
    assert_not_nil i.id
    assert_equal i.value, '{1.3, 2.3}'
    assert_nil i.value_bool
    assert_nil i.value_date
    assert_nil i.value_float
    assert_nil i.value_int
    assert_equal i.value_lat, 1.3
    assert_equal i.value_lng, 2.3

    i = le.items.create(:value => '[1.4, 2.4]')
    assert_not_nil i.id
    assert_equal i.value, '[1.4, 2.4]'
    assert_nil i.value_bool
    assert_nil i.value_date
    assert_nil i.value_float
    assert_nil i.value_int
    assert_equal i.value_lat, 1.4
    assert_equal i.value_lng, 2.4

    i = le.items.create(:value => '[1.4x, 2.4]')
    assert_not_nil i.id
    assert_equal i.value, '[1.4x, 2.4]'
    assert_nil i.value_bool
    assert_nil i.value_date
    assert_nil i.value_float
    assert_nil i.value_int
    assert_nil i.value_lat
    assert_nil i.value_lng

    i = le.items.create(:value => '1z')
    assert_not_nil i.id
    assert_equal i.value, '1z'
    assert_nil i.value_bool
    assert_nil i.value_date
    assert_nil i.value_float
    assert_nil i.value_int
    assert_nil i.value_lat
    assert_nil i.value_lng

    i = le.items.create(:value => '1/1/z2010')
    assert_not_nil i.id
    assert_equal i.value, '1/1/z2010'
    assert_nil i.value_bool
    assert_nil i.value_date
    assert_nil i.value_float
    assert_nil i.value_int
    assert_nil i.value_lat
    assert_nil i.value_lng
  end

  def test_should_reset_generated_values
    le = LogEntry.find_by_id(log_entries(:log_one))
    i = le.items.create(:value => '1')
    assert_not_nil i.id
    assert_equal i.value, '1'
    assert_equal i.value_bool, true
    assert_nil i.value_date
    assert_equal i.value_float, 1.0
    assert_equal i.value_int, 1
    assert_nil i.value_lat
    assert_nil i.value_lng

    i.value = '1x'
    i.save
    i.reload
    assert_not_nil i.id
    assert_equal i.value, '1x'
    assert_nil i.value_bool
    assert_nil i.value_date
    assert_nil i.value_float
    assert_nil i.value_int
    assert_nil i.value_lat
    assert_nil i.value_lng

    i.value = '0'
    i.save
    i.reload
    assert_not_nil i.id
    assert_equal i.value, '0'
    assert_equal i.value_bool, false
    assert_nil i.value_date
    assert_equal i.value_float, 0.0
    assert_equal i.value_int, 0
    assert_nil i.value_lat
    assert_nil i.value_lng

    i.value = '[1.4, 2.4]'
    i.save
    i.reload
    assert_not_nil i.id
    assert_equal i.value, '[1.4, 2.4]'
    assert_nil i.value_bool
    assert_nil i.value_date
    assert_nil i.value_float
    assert_nil i.value_int
    assert_equal i.value_lat, 1.4
    assert_equal i.value_lng, 2.4

    i.value = '1/2/2010 10:08:01 PM'
    i.save
    i.reload
    assert_not_nil i.id
    assert_equal i.value, '1/2/2010 10:08:01 PM'
    assert_nil i.value_bool
    assert_equal i.value_date, DateTime.new(2010, 1, 2, 22, 8, 1)
    assert_nil i.value_float
    assert_nil i.value_int
    assert_nil i.value_lat
    assert_nil i.value_lng
  end

  def test_should_add_tags
    i = LogEntryItem.find_by_id(log_entry_items(:item_one))
    assert_not_nil i
    assert_equal i.tag_list, []
    assert_equal i.tags.count, 0
    i.tag_list = ['tag1', 'tag2']
    assert i.save
    i.tags.reload
    assert_equal i.tag_list, ['tag1', 'tag2']
    assert_equal i.tags.count, 2
    # Check resetting the full list
    i.tag_list = 'tag3'
    assert i.save
    i.tags.reload
    assert_equal i.tag_list, ['tag3']
    assert_equal i.tags.count, 1
    # Check adding a tag
    i.tag_list.add('tag4')
    assert i.save
    i.tags.reload
    assert_equal i.tag_list, ['tag3', 'tag4']
    assert_equal i.tags.count, 2
    # Check no repeats and check adding an array of tags
    i.tag_list.add(['tag4', 'tag5', 'tag6'])
    assert i.save
    i.tags.reload
    assert_equal i.tag_list, ['tag3', 'tag4', 'tag5', 'tag6']
    assert_equal i.tags.count, 4
  end

  def test_should_remove_tags
    i = LogEntryItem.find_by_id(log_entry_items(:item_one))
    assert_not_nil i
    i.tag_list = 'tag1, tag2'
    assert i.save
    i.tags.reload
    assert_equal i.tags.count, 2
    i.tag_list.remove('tag1')
    assert i.save
    i.tags.reload
    assert_equal i.tag_list, ['tag2']
    assert_equal i.tags.count, 1
  end

  def test_should_not_remove_missing_tag
    i = LogEntryItem.find_by_id(log_entry_items(:item_one))
    assert_not_nil i
    i.tag_list = 'tag1, tag2'
    assert i.save
    i.tags.reload
    assert_equal i.tags.count, 2
    i.tag_list.remove('tag3')
    assert i.save
    i.tags.reload
    assert_equal i.tag_list, ['tag1', 'tag2']
    assert_equal i.tags.count, 2
  end

  def test_should_find_when_tagged
    tagged = LogEntryItem.tagged_with('tag1')
    tag_count = tagged.count
    i = LogEntryItem.find_by_id(log_entry_items(:item_one))
    assert_nil tagged.index(i)
    i.tag_list = 'tag1'
    assert i.save
    i.tags.reload
    assert i.tags.count, 1
    tagged = LogEntryItem.tagged_with('tag1')
    assert_equal tagged.count, tag_count + 1
    assert_not_nil tagged.index(i)
  end

  def test_should_find_when_tagged_with_multiple
    i1 = LogEntryItem.find_by_id(log_entry_items(:item_one))
    i1.tag_list = 'tag1, tag2'
    assert i1.save
    i2 = LogEntryItem.find_by_id(log_entry_items(:item_two))
    i2.tag_list = 'tag1, tag3'
    assert i2.save
    tagged = LogEntryItem.tagged_with('tag1')
    assert_not_nil tagged.index(i1)
    assert_not_nil tagged.index(i2)
    tagged = LogEntryItem.tagged_with('tag1, tag2')
    assert_not_nil tagged.index(i1)
    assert_nil tagged.index(i2)
  end
end
