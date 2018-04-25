class StaticController < ApplicationController
  def quiz
	@questions = Question.all


  end
end