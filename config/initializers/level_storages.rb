# frozen_string_literal: true

class LevelStorages
  FILE_PATH = 'db/shakespeare_data.yml'

  attr_accessor :storage_1, :storage_2

  def initialize
    @data = load_data
    @storage_1 = make_storage_1
    @storage_2 = make_storage_2
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

  def print_usage(description)
    mb = GetProcessMem.new.mb
    "#{description} - MEMORY USAGE(MB): #{mb.round}"
  end

  private

  def load_data
    data = YAML.load_file(FILE_PATH)
    data.each { |_name, strings| strings.compact! }
  end
end

STORAGES = LevelStorages.new
