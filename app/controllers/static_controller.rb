class StaticController < ApplicationController
  def quiz
	@questions = Question.all
	if params["who"]
		@answer_prefill = params[:who]
		i = 0
	  	@questions.each do |question|
	  		if question.answer == "[:enter proof:]"

	  			stripText = (question.text).gsub(/\s+/, "")
	  			statements = stripText.split("|-")
	  			premise = statements[0]
	  			conclusion = statements[1]
				begin
			        question.error = false
			        if params["who"][i] == ""
			        	question.res_string = ""
			        else
						if Engine.proof_valid?(premise, conclusion, params["who"][i])
							question.res_string = "Correct!"
							question.response = "[:enter proof:]"
						else
							question.res_string = "You have logic errors."
							question.response = "wrong"
						end
		        	end
				rescue => e
			        question.error = true

			        question.res_string = "Error found."
			        question.err_message = e.message + (e.line ? " | on line " + e.line.to_s : "")
			        question.line_no = e.formula
			        question.response = "wrong"
				end
			end
  			question.response = params["who"][i]
		i = i + 1
		end
	else
		@answer_prefill = ""
	end

  end
end