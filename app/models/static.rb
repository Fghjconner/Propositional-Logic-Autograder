require 'set'

module Static
	class Problem
		def initialize(question, answer, type)
			@question = question
			@answer = answer
			@type = type #1 = fill-in-the-blank. 2 = multiple choice. 3 = write proof.
		end
		
		attr_accessor :question, :answer, :type

		def verdict(response)
			if response == :answer
				return true
			else
				return false
			end
		end
	end

	def self.proof_questions
		[Problem.new("Do apples lie?", "yes", 1), Problem.new("Do apples lie?", "yes", 1)]
	end

	def self.mc_questions
		[Problem.new("Do apples lie?", "yes", 1),Problem.new("Do apples lie?", "yes", 1)]
	end
	
end
