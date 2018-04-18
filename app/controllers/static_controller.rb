class StaticController < ApplicationController
  def quiz
  	@all_questions = Static.mc_questions
	#Static.proof_questions + Static.mc_questions


  	for question in @all_questions
		if params[:response] == "P"
			@result = question.verdict(params[:response])
		elsif params[:response].blank? == false  && params[:response] != "P" 
			@result = question.verdict(params[:response])
		elsif
			@result = ""
		end
	end

  end
end