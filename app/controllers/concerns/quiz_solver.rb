# frozen_string_literal: true

module QuizSolver
  extend ActiveSupport::Concern

  def find_1(question)
    QUIZ_DATA.storage_1[question.gsub(/\W+/, '')]
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
    QUIZ_DATA.search_by_tree(question)
  end

  def find_8(question)
    QUIZ_DATA.search_8(question)
  end

  private

  def find_absent(key)
    QUIZ_DATA.storage_2[key.size + 1].each do |str|
      absent_word = check(key, str)
      return absent_word if absent_word 
    end
    nil 
  end

  def check(key, str)
    missmatch = nil
    str.each_index do |i|
      return if missmatch && str[i + 1] != key[i]

      if !missmatch && str[i] != key[i]
        return if key[i] != str[i + 1]
        missmatch = str[i]
      end
    end
    missmatch || str[-1] 
  end 
end
