class Question < ApplicationRecord
	attr_accessor :response
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
