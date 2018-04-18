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
				return "Correct!"
			else
				return "Incorrect."
			end
		end
	end

	def self.proof_questions
		[Problem.new("What sentence would fit the following blank to make the following expression true? \n P->Q, _ |- Q", "P", 1), Problem.new("Complete the following premise so that the sequence is valid. \n (P & Q)v(___) |- ((P & Q) v R) v S", "RvS", 1)]
	end

	def self.mc_questions
		[Problem.new("Complete the following premise so that the sequence is valid. \n PvQ->R, P, ___->S, F |- S", "F&R", 1),Problem.new("Is 431 the best class in the software track?", "yes", 1)]
	end
	
end
