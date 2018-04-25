class StaticController < ApplicationController
  def quiz
	@questions = Question.all

	i = 0
  	@questions.each do |question|
  		if i == 0
	  		question.response = "yes"
  		else
  			question.response = "no"
		end
  		i = i + 1
	end

  end
end