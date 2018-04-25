class StaticController < ApplicationController
  def quiz
	@questions = Question.all
	
	if params["who"]
		i = 0
	  	@questions.each do |question|
  			question.response = params["who"][i]
		i = i + 1
		end
	end

  end
end