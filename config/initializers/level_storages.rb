# frozen_string_literal: true

class LevelStorages
  FILE_PATH = 'db/shakespeare_data.yml'.freeze
  TREE_DEPTH = 4

  attr_accessor :storage_1, :storage_2, :tree_storage, :storage_8

  def initialize
    @data = load_data
    @storage_1 = make_storage_1
    @storage_2 = make_storage_2
    @tree_storage = make_tree_storage
  end

  def make_storage_1
    storage = {}
    @data.each do |work_name, strings|
      frozen_work_name = work_name.freeze
      str_as_key_storage = strings.map { |string| [string.gsub(/\W+/, ''), frozen_work_name] }.to_h
      storage.merge!(str_as_key_storage)
    end
    storage
  end

  def make_storage_2
    storage = {}
    @data.each do |_work_name, strings|
      strings.each do |str|
        words = str.scan(/([\w'%]+)/).flatten
        storage[words.size] ||= []
        storage[words.size] << words
      end
    end
    storage
  end

  def make_tree_storage
    storage = {}
    shared_data.each do |str_id, str|
      frequency_counter = make_frequency_counter(str)

      limited_frequency_counter = frequency_counter.first(TREE_DEPTH).to_h

      insert(limited_frequency_counter, str_id, storage)
    end
    storage
  end

  def insert(frequency_counter, str_id, storage)
    char, frequency = frequency_counter.shift

    storage[char] ||= {}
    storage[char][frequency] ||= {}

    if frequency_counter.any?
      insert(frequency_counter, str_id, storage[char][frequency])
    else
      storage[char][frequency][:str_id] ||= []
      storage[char][frequency][:str_id] << str_id
    end
  end

  def search_by_tree(str)
    frequency_counter = make_frequency_counter(str)

    key_path = frequency_counter.first(TREE_DEPTH).flatten
    key_path << :str_id

    str_ids = @tree_storage.dig(*key_path)

    return if str_ids.nil?

    str = sort_string(str)
    str_ids.each do |id|
      return shared_data[id] if sort_string(shared_data[id]) == str
    end
    nil
  end

  # input "aaa bbd" -> output { 'a' => 3, 'b' => 2, ' ' => 1, 'd' => 1 }
  def make_frequency_counter(str)
    frequency_counter = {}
    str = clean(str)
    str.chars.map do |char|
      frequency_counter[char] = (frequency_counter[char] || 0) + 1
    end
    frequency_counter
  end

  def make_storage_8
    storage = {}
    shared_data.each do |str_id, str|
      length = clean(str).length
      storage[length] = (storage[length] || []) << str_id 
    end
    storage
  end

  def search_8(str)
    key = clean(str).length
    str = clean(str)
    frequency_c1 = make_frequency_counter(str)

    finded = storage_8[key].select do |str_id|
      frequency_c2 = make_frequency_counter(shared_data[str_id])

      (-2..2).include?(frequency_c1.size - frequency_c2.size) &&
      compare(frequency_c1, frequency_c2)
    end

    finded
  end

  def compare(frequency_c1, frequency_c2)
    offense_count = 0
    frequency_c1.each do |char, count|
      if frequency_c2[char].nil?
        offense_count +=1
        next
      end
      
      offense_count +=1 unless (-2..2).include? (frequency_c2[char] - count)

      return false if offense_count > 1
    end
    true
  end

  def shared_data
    curr_id = 0
    @shared_data ||= @data.flat_map do |_name, strings|
      strings.map { |str| [curr_id += 1, str] }
    end.to_h
  end

  def sort_string(str)
    clean(str).chars.sort.join
  end

  def clean(str)
    str.scan(/[\w'\s]+/).join
  end

  def find_absent(key)
    missmatch = nil
    @storage_2[key.size + 1].each do |str|
      str.each_index do |i|
        if missmatch
          if str[i + 1] != key[i]
            missmatch = nil
            break
          end
          return missmatch if key.size == i + 1
        end

        next unless !missmatch && str[i] != key[i]
        break if key[i] != str[i + 1]

        missmatch = str[i]
      end
    end
    missmatch
  end

  def load_data
    data = YAML.load_file(FILE_PATH)
    data.each { |_name, strings| strings.compact! }
  end
end

STORAGES = LevelStorages.new
