require 'set'

module Engine

	class FormulaError < StandardError
		def initialize(message, formula, line=nil)
			@formula = formula
			@line = line
			super(message)
		end
		
		attr_accessor :line, :formula
	end
	
	class ProofError < StandardError
		def initialize(message, formula, line=nil)
			@formula = formula
			@line = line
			super(message)
		end
		
		attr_accessor :line, :formula
	end

	class WFF
		def ==(other)
			return other.respond_to?(:state) && self.state == other.state
		end

		def eql?(other)
			return self.class == other.class && self == other
		end

		def hash
			state.hash
		end
	end

	class Negation < WFF
		def initialize(sub)
			@sub = sub
		end

		def type
			:negation
		end

		attr_reader :sub

		def state
			self.instance_variables.map { |variable| self.instance_variable_get variable }
		end
	end

	class Connective < WFF
		def initialize(type, sub1, sub2)
			@type = type
			@sub1 = sub1
			@sub2 = sub2
		end

		attr_reader :type, :sub1, :sub2

		def state
			self.instance_variables.map { |variable| self.instance_variable_get variable }
		end
	end

	def self.denial?(first, second)
		return (first.respond_to?('type') && first.type == :negation && first.sub == second) || (second.respond_to?('type') && second.type == :negation && second.sub == first)
	end

	class Line
		def initialize(line_num, conclusion, rule, sources, assumptions, discharged)
			@line_num = line_num
			@conclusion = conclusion
			@rule = rule

			if sources.respond_to?('each')
				@sources = sources
			else
				@sources = Set[sources]
			end

			if assumptions.respond_to?('each')
				@assumptions = assumptions
			else
				@assumptions = Set[assumptions]
			end

			# Makes rules using assumptions easier to verify by referencing itself
			@assumptions.map! { |x|  x == :itself ? self : x}

			@discharged = discharged
		end

		attr_reader :line_num, :conclusion, :rule, :sources, :assumptions, :discharged

		def ==(other)
			return false unless self.class == other.class

			self_assumptions = self.assumptions
			other_assumptions = other.assumptions

			# Unfortunately, self reference makes comparison harder
			self_assumptions.map! { |x|  x.equal?(self) ? :itself : x}
			other_assumptions.map! { |x|  x.equal?(other) ? :itself : x}

			return	self.line_num == other.line_num &&
					self.conclusion == other.conclusion &&
					self.rule == other.rule &&
					self.sources == other.sources &&
					self_assumptions == other_assumptions &&
					self.discharged == other.discharged
		end

		def eql?(other)
			return self == other
		end

		def state
			self.instance_variables.map { |variable| self.instance_variable_get variable }
		end

		def valid?
			return Verifier.send("verify_#{@rule}", self)
		end
	end

	PRIORITIES = {"~" => 4, "v" => 3, "&" => 3, "->" => 2, "<->" => 1}
	TYPES = {"v" => :disjunction, "&" => :conjunction, "->" => :conditional, "<->" => :biconditional}
	MAP = {"-" => "->", "<" => "<->"}

	def self.parse_formula string
		raise "Argument is empty" if string.nil? or string.length == 0

		parenDepth = 0
		minDepth = 999999

		foundIndex = -1
		foundDepth = 999999
		foundPriority = 5

		currentIndex = 0

		while currentIndex < string.length
			case string[currentIndex]
			when "("
				parenDepth += 1
				currentIndex += 1
			when ")"
				raise "Tried to close too many parenthesis" unless parenDepth > 0

				parenDepth -= 1
				currentIndex += 1
			when *(PRIORITIES.keys + MAP.keys)
				symbol = string[currentIndex]
				symbol = MAP[symbol] if MAP.key?(symbol)

				raise "Improperly formatted operator" unless string[currentIndex, symbol.length] == symbol

				if parenDepth < foundDepth or (parenDepth == foundDepth and PRIORITIES[symbol] < foundPriority)
					foundIndex = currentIndex
					foundDepth = parenDepth
					foundPriority = PRIORITIES[symbol]
				end

				minDepth = [parenDepth, minDepth].min

				currentIndex += symbol.length
			when 'A'..'Z'
				minDepth = [parenDepth, minDepth].min
				currentIndex += 1
			else
				raise "Unknown character '" + string[currentIndex] + "' encountered"
			end
		end

		raise "Failed to close parenthesis" unless parenDepth == 0

		raise "Malformed parenthesis" unless string[0, minDepth] == ("(" * minDepth) and string[-minDepth, minDepth] == (")" * minDepth)

		string = string[minDepth, string.length - (2*minDepth)]
		foundIndex -= minDepth

		return string if string =~ /^[A-Z]$/

		raise "Malformed expression" if foundIndex == -1

		symbol = string[foundIndex]
		symbol = MAP[symbol] if MAP.key?(symbol)


		case symbol
		when "~"
			return Negation.new(parse_formula(string[foundIndex+symbol.length..-1]))
		else
			return Connective.new(TYPES[symbol], parse_formula(string[0,foundIndex]), parse_formula(string[foundIndex+symbol.length..-1]))
		end
	end

	def self.parse_line string, lines
		parts = string.split

		line_num = parts[1][1..-2].to_i

		begin
			conclusion = parse_formula(parts[2])
		rescue => e
			raise FormulaError.new("Could not parse formula: " + e.message, parts[2])
		end

		assumptions = Set.new(parts[0].split(',').map { |i| i.to_i == line_num ? :itself : lines[i.to_i-1]}) #One indexing sucks! (also handle assumptions relying on themselves)

		discharged = nil

		case parts[3]
		when "A"
			rule = :assumption
			source_list = ""
		when /^(\d+(?:,\d+)*)\&I$/  #Matches &intro, putting the sources into the first capture group
			rule = :amp_intro
			source_list = $1
		when /^(\d+(?:,\d+)*)\&E$/  #Matches &intro, putting the sources into the first capture group
			rule = :amp_elim
			source_list = $1
		when /^(\d+(?:,\d+)*)vI$/  #You know the drill
			rule = :wedge_intro
			source_list = $1
		when /^(\d+(?:,\d+)*)vE$/
			rule = :wedge_elim
			source_list = $1
		when /^(\d+(?:,\d+)*)->I\((\d+)\)$/  #Curveball! Also puts the discharged assumption into second capture group
			rule = :arrow_intro
			source_list = $1
			discharged = lines[$2.to_i-1]  #And, we're back to normal
		when /^(\d+(?:,\d+)*)->E$/
			rule = :arrow_elim
			source_list = $1
		when /^(\d+(?:,\d+)*)RAA\((\d+)\)$/  #But wait, discharging again
			rule = :reductio
			source_list = $1
			discharged = lines[$2.to_i-1]
		else
			raise FormulaError.new("Could not parse proof.", parts[3])
		end

		sources = Set.new(source_list.split(',').map { |i| lines[i.to_i-1]}) #one indexing still sucks

		return Line.new(line_num, conclusion, rule, sources, assumptions, discharged)
	end

	def self.proof_valid?(premesis, conclusion, proof_string)
		premesis = Set.new(premesis.split(/\s*,\s*/).map { |prem|
			begin
				parse_formula(prem)
			rescue => e
				raise FormulaError.new("Could not parse premise: " + e.message, prem)
			end
		})

		begin
			conclusion = parse_formula(conclusion)
		rescue => e
			raise FormulaError.new("Could not parse conclusion: " + e.message, conclusion)
		end

		proof = []
		proof_string.lines.each_with_index { |line, i|
			begin
				proof.push(parse_line(line, proof))
			rescue => e
				if e.respond_to?(:line=)
					e.line = (i+1)
				end
				raise e
			end
		}

		assumptions = Set.new(proof[-1].assumptions.map {|line| line.conclusion})

		proof.each_with_index { |line, i|
			unless line.valid?
				raise ProofError.new("Invalid proof, line #{i+1} does not follow", proof_string.lines[i])
			end
		}
		return false unless assumptions <= premesis
		return false unless proof[-1].conclusion == conclusion

		return true
	end
end