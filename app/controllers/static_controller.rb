class StaticController < ApplicationController
  def quiz
  	@all_questions = Static.proof_questions + Static.mc_questions


  	for question in @all_questions
		if params[:response]
			@result = question.verdict(params[:response])
		else
			@result = ""
		end
	end

  end
end