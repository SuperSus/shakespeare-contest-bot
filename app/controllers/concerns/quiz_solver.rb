# frozen_string_literal: true

module QuizSolver
  extend ActiveSupport::Concern

  def find_1(question)
    STORAGES.storage_1[question.gsub(/\W+/, '')]
  end

  def find_2_3_4(question)
    answer = question.split("\n").map do |sentence|
      key = sentence.scan(/([\w'%]+)/).flatten
      result = find_absent(key.reject { |word| word == '%WORD%' })

      return if result.nil?

      result
    end

    answer.join(',')
  end

  def find_5(question)
    key = question.scan(/([\w'%]+)/).flatten

    key.each_index do |i|
      probably_key = key.values_at(0...i, (i + 1)..-1)
      changed_word = key[i]
      res = find_absent(probably_key)
      return [res, changed_word].join(',') if res
    end
  end

  def find_6_7(question)
    STORAGES.search_by_tree(question)
  end

  private

  def find_absent(key)
    missmatch = nil
    STORAGES.storage_2[key.size + 1].each do |str|
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
end
