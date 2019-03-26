class Loader
  FILE_PATH = 'db/shakespeare_data.yml'
  
  attr_accessor :storage_1, :storage_2 

  def initialize
    @data = load_data
    @storage_1 = make_storage_1
    @storage_2 = make_economy
  end

  def make_storage_1
    storage = {}
    @data.each do |work|
      work.each do |act, strings|
        frozen_act = act.freeze
        str_as_key_storage = strings.map { |string| [string, frozen_act] }.to_h
        storage.merge!(str_as_key_storage)
      end 
    end
    storage
  end

  def make_storage_2 
    storage = {}
    @data.each do |work|
      work.each do |_act, strings|
        strings.each do |str|
          words = str.scan(/([\w'%]+)/).flatten
          
          my = words.size.times.map do |i|
            key = words.reject.with_index{ |_v, index| i == index }.join
            [key, words[i]]
          end.to_h

          storage.merge!(my)
        end 
      end   
    end
    storage
  end

  def make_economy
    storage = {}
    @data.each do |work|
      work.each do |_act, strings|
        strings.each do |str|
          words = str.scan(/([\w'%]+)/).flatten
          storage[words.size] ||= [] 
          storage[words.size] << words
        end 
      end   
    end
    storage
  end

  def find_2(s)
     key = s.scan(/([\w'%]+)/).flatten.join

     @storage_2[key]
  end

  def find_2e(s)
    key = s.scan(/([\w'%]+)/).flatten

    t1 = Time.now
      res1= find_absent(key)
    puts Time.now - t1

    res1
  end

  def find_absent (key)
    missmatch = nil
    @storage_2[key.size + 1].each do |str|
      str.each_index do |i| 
        if missmatch
          if str[i + 1] != key[i]
            missmatch = nil
            break
          end
          return missmatch if key.size == i+1
        end

        if !missmatch && str[i] != key[i] 
          break if key[i] != str[i + 1]
          missmatch = str[i]
        end
      end 
    end
    missmatch 
  end

  private
  
  def load_data
    YAML::load_file(FILE_PATH)
  end
end

$loader = Loader.new

