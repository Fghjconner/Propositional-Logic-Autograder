require 'set'

module Verifier

	# Check sources
	# Check assumptions
	# Check conclusion
	# Check discharge


	def self.verify_assumption line
		# Check sources
		return false unless line.sources.empty?
		# Check assumptions
		return false unless line.assumptions.size == 1 and line.assumptions.include?(line)
		# Check discharge
		return false unless line.discharged == nil
		# No conclusion checking needed (can conclude *anything*)

		return true
	end

	def self.verify_amp_intro line
		# Check sources
		return false unless line.sources.size == 2

		# Check assumptions
		assumptions = Set[]
		line.sources.each { | source | assumptions |= source.assumptions}
		return false unless line.assumptions == assumptions

		sources = line.sources.to_a
		source1 = sources[0].conclusion
		source2 = sources[1].conclusion

		# Check discharge
		return false unless line.discharged == nil

		# Check conclusion
		return false unless line.conclusion == Engine::Connective.new(:conjunction, source1, source2) or line.conclusion == Engine::Connective.new(:conjunction, source2, source1)

		return true
	end

	def self.verify_amp_elim line
		# Check sources
		return false unless line.sources.size == 1

		source = line.sources.to_a[0]

		# Check assumptions
		return false unless line.assumptions == source.assumptions
		
		# Check discharge
		return false unless line.discharged == nil

		# Check conclusion
		return false unless source.conclusion.type == :conjunction
		return false unless source.conclusion.sub1 == line.conclusion or source.conclusion.sub2 == line.conclusion

		return true
	end

	def self.verify_wedge_intro line
		# Check sources
		return false unless line.sources.size == 1

		source = line.sources.to_a[0]

		# Check assumptions
		return false unless line.assumptions == source.assumptions
		
		# Check discharge
		return false unless line.discharged == nil

		# Check conclusion
		return false unless line.conclusion.type == :disjunction
		return false unless line.conclusion.sub1 == source.conclusion or line.conclusion.sub2 == source.conclusion

		return true
	end

	def self.verify_wedge_elim line
		# Check sources
		return false unless line.sources.size == 2

		# Check assumptions
		assumptions = Set[]
		line.sources.each { | source | assumptions |= source.assumptions}
		return false unless line.assumptions == assumptions

		sources = line.sources.to_a
		source1 = sources[0].conclusion
		source2 = sources[1].conclusion
		
		# Check discharge
		return false unless line.discharged == nil

		# Check conclusion
		if source1.type == :disjunction
			if Engine::denial?(source1.sub1, source2) and source1.sub2 == line.conclusion
				return true
			elsif Engine::denial?(source1.sub2, source2) and source1.sub1 == line.conclusion
				return true
			end
		elsif source2.type == :disjunction
			if Engine::denial?(source2.sub1, source1) and source2.sub2 == line.conclusion
				return true
			elsif Engine::denial?(source2.sub2, source1) and source2.sub1 == line.conclusion
				return true
			end
		end
		return false
	end

	def self.verify_arrow_intro line
		# Check sources
		return false unless line.sources.size == 1

		source = line.sources.to_a[0]

		# Check assumptions
		return false unless line.assumptions == (source.assumptions - Set[line.discharged])
		
		# Check discharge
		return false unless source.assumptions.include?(line.discharged)

		# Check conclusion
		return false unless line.conclusion == Engine::Connective.new(:conditional, line.discharged.conclusion, source.conclusion)

		return true
	end

	def self.verify_arrow_elim line
		# Check sources
		return false unless line.sources.size == 2

		# Check assumptions
		assumptions = Set[]
		line.sources.each { | source | assumptions |= source.assumptions}
		return false unless line.assumptions == assumptions

		sources = line.sources.to_a
		source1 = sources[0].conclusion
		source2 = sources[1].conclusion

		# Check discharge
		return false unless line.discharged == nil

		# Check conclusion
		return false unless source1 == Engine::Connective.new(:conditional, source2, line.conclusion) or source2 == Engine::Connective.new(:conditional, source1, line.conclusion)

		return true
	end

	def self.verify_reductio line
		# Check sources
		return false unless line.sources.size == 2

		# Check assumptions
		assumptions = Set[]
		line.sources.each { | source | assumptions |= source.assumptions}
		return false unless line.assumptions == (assumptions - Set[line.discharged])

		sources = line.sources.to_a
		source1 = sources[0].conclusion
		source2 = sources[1].conclusion
		
		# Check discharge
		return false unless assumptions.include?(line.discharged)

		# Check conclusion
		return false unless Engine::denial?(source1, source2)
		return false unless Engine::denial?(line.discharged.conclusion, line.conclusion)

		return true
	end
end