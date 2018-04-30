class Question < ApplicationRecord
	attr_accessor :response
	attr_accessor :res_string
	attr_accessor :error
	attr_accessor :err_message
	attr_accessor :line_no

	def result(res)
		if res == self.answer
			return "Correct!"
		elsif res == ""
			return ""
		elsif @response == nil
			return ""
		else
			return "Incorrect"
		end
	end
end
