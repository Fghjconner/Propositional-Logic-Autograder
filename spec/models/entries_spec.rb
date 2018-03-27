require 'app/controllers/entries_controller.rb'
require 'set'

describe Engine do

	describe "#parse_formula" do
		it "should be defined" do
			expect {Engine.parse_formula("A")}.not_to raise_error
		end

		it "should error on empty string" do
			expect{Engine.parse_formula("")}.to raise_error(RuntimeError)
		end

		it "should error on unkown characters" do
			expect{Engine.parse_formula("?")}.to raise_error(RuntimeError)
		end

		it "should error on incorrectly formatted operators" do
			expect{Engine.parse_formula("(A<-B)")}.to raise_error(RuntimeError)
			expect{Engine.parse_formula("(A>B)")}.to raise_error(RuntimeError)
			expect{Engine.parse_formula("(A-B)")}.to raise_error(RuntimeError)
		end

		it "should error on unmatched parenthesis" do
			expect{Engine.parse_formula("(AvB")}.to raise_error(RuntimeError)
			expect{Engine.parse_formula("AvB)")}.to raise_error(RuntimeError)
		end

		it "should error on missing arguments" do
			expect{Engine.parse_formula("(Av)")}.to raise_error(RuntimeError)
			expect{Engine.parse_formula("(~)")}.to raise_error(RuntimeError)
			expect{Engine.parse_formula("->B")}.to raise_error(RuntimeError)
		end

		it "should parse single variables" do
			expect(Engine.parse_formula("A")).to eq ("A")
			expect(Engine.parse_formula("Z")).to eq ("Z")
			expect(Engine.parse_formula("Q")).to eq ("Q")
		end

		it "should parse negations" do
			expect(Engine.parse_formula("~A")).to eq(Engine::Negation.new("A"))
		end

		it "should parse nested negations" do
			expect(Engine.parse_formula("(~(~A))")).to eq(Engine::Negation.new(Engine::Negation.new("A")))
			expect(Engine.parse_formula("~~A")).to eq(Engine::Negation.new(Engine::Negation.new("A")))
		end

		it "should parse conjunctions" do
			expect(Engine.parse_formula("(A&B)")).to eq(Engine::Connective.new(:conjunction, "A", "B"))
		end

		it "should parse disjunctions" do
			expect(Engine.parse_formula("(AvB)")).to eq(Engine::Connective.new(:disjunction, "A", "B"))
		end

		it "should parse conditionals" do
			expect(Engine.parse_formula("(A->B)")).to eq(Engine::Connective.new(:conditional, "A", "B"))
		end

		it "should parse biconditionals" do
			expect(Engine.parse_formula("(A<->B)")).to eq(Engine::Connective.new(:biconditional, "A", "B"))
		end

		it "should parse compound sentences" do
			expect(Engine.parse_formula("((A&(~B))->C)")).to eq(Engine::Connective.new(:conditional, Engine::Connective.new(:conjunction, "A", Engine::Negation.new("B")), "C"))
			expect(Engine.parse_formula("(A<->(((~B)vC)->D))")).to eq(Engine::Connective.new(:biconditional, "A", Engine::Connective.new(:conditional, Engine::Connective.new(:disjunction, Engine::Negation.new("B"), "C"), "D")))
			expect(Engine.parse_formula("((AvB)&(CvD))")).to eq(Engine::Connective.new(:conjunction, Engine::Connective.new(:disjunction, "A", "B"), Engine::Connective.new(:disjunction, "C", "D")))
		end

		it "should handle omitted parenthesis" do
			expect(Engine.parse_formula("A&~B->C")).to eq(Engine::Connective.new(:conditional, Engine::Connective.new(:conjunction, "A", Engine::Negation.new("B")), "C"))
			expect(Engine.parse_formula("A<->~BvC->D")).to eq(Engine::Connective.new(:biconditional, "A", Engine::Connective.new(:conditional, Engine::Connective.new(:disjunction, Engine::Negation.new("B"), "C"), "D")))
			expect(Engine.parse_formula("(A->B)vC<->D")).to eq(Engine::Connective.new(:biconditional, Engine::Connective.new(:disjunction, Engine::Connective.new(:conditional, "A", "B"), "C"), "D"))
		end

		it "should handle excess parenthesis" do
			expect(Engine.parse_formula("((((A&(~B)))->(C)))")).to eq(Engine::Connective.new(:conditional, Engine::Connective.new(:conjunction, "A", Engine::Negation.new("B")), "C"))
			expect(Engine.parse_formula("((A<->(((((~B))vC))->D)))")).to eq(Engine::Connective.new(:biconditional, "A", Engine::Connective.new(:conditional, Engine::Connective.new(:disjunction, Engine::Negation.new("B"), "C"), "D")))
		end
	end

	describe "#parse_line" do
		before(:all) do
			@lines = [
				Engine::Line.new(1, "A", :assumption, Set[], :itself, nil),
				Engine::Line.new(2, "B", :assumption, Set[], :itself, nil),
				Engine::Line.new(3, Engine.parse_formula("A&B"), :assumption, Set[], :itself, nil),
				Engine::Line.new(4, Engine.parse_formula("AvB"), :assumption, Set[], :itself, nil),
				Engine::Line.new(5, Engine.parse_formula("~A"), :assumption, Set[], :itself, nil),
				Engine::Line.new(6, Engine.parse_formula("A->B"), :assumption, Set[], :itself, nil)
			]

			source = Set[@lines[0], @lines[1]]
			@lines << Engine::Line.new(7, Engine.parse_formula("A&B"), :amp_intro, source, source, nil)
		end

		it "should be defined" do
			expect{Engine.parse_line("1 (1) A A", @lines)}.not_to raise_error
		end

		it "should parse assumptions" do
			expect(Engine.parse_line("9 (9) A A", @lines)).to eq(Engine::Line.new(9, "A", :assumption, Set[], :itself, nil))
			expect(Engine.parse_line("12 (12) (A<->B) A", @lines)).to eq(Engine::Line.new(12, Engine.parse_formula("(A<->B)"), :assumption, Set[], :itself, nil))
		end

		it "should parse ampersand introduction" do
			source = Set[@lines[0], @lines[1]]
			expect(Engine.parse_line("1,2 (9) A&B 1,2&I", @lines)).to eq(Engine::Line.new(9, Engine.parse_formula("A&B"), :amp_intro, source, source, nil))
		end

		it "should parse ampersand elimination" do
			expect(Engine.parse_line("3 (9) A 3&E", @lines)).to eq(Engine::Line.new(9, "A", :amp_elim, @lines[2], @lines[2], nil))
		end

		it "should parse wedge introduction" do
			expect(Engine.parse_line("1 (9) AvZ 1vI", @lines)).to eq(Engine::Line.new(9, Engine.parse_formula("AvZ"), :wedge_intro, @lines[0], @lines[0], nil))
		end

		it "should parse wedge elimination" do
			source = Set[@lines[3], @lines[4]]
			expect(Engine.parse_line("4,5 (9) B 4,5vE", @lines)).to eq(Engine::Line.new(9, "B", :wedge_elim, source, source, nil))
		end

		it "should parse arrow introduction" do
			expect(Engine.parse_line("2 (9) A->A&B 7->I(1)", @lines)).to eq(Engine::Line.new(9, Engine.parse_formula("A->A&B"), :arrow_intro, @lines[6], @lines[1], @lines[0]))
		end

		it "should parse arrow elimination" do
			source = Set[@lines[0], @lines[5]]
			expect(Engine.parse_line("1,6 (9) B 1,6->E", @lines)).to eq(Engine::Line.new(9, "B", :arrow_elim, source, source, nil))
		end

		it "should parse reductio ad absurdum" do
			expect(Engine.parse_line("1 (9) A 1,5RAA(5)", @lines)).to eq(Engine::Line.new(9, "A", :reductio, Set[@lines[0], @lines[4]], @lines[0], @lines[4]))
		end

		it "should handle weird spacing" do
			expect(Engine.parse_line("1    ( 9)    A        1,5 RAA (5)", @lines)).to eq(Engine::Line.new(9, "A", :reductio, Set[@lines[0], @lines[4]], @lines[0], @lines[4]))
		end
	end
end