require 'pry'

class LogicController < ApplicationController
    def logic
		# binding.pry
        if params[:submit] == 'Proof'
            premises = params[:premises]
            conclusion = params[:conclusion]
            proof_lines = params[:proof_lines]
            data = parse_input(premises, conclusion, proof_lines)
            respond_to do |format|
                format.json { render json: data }
            end

        end
        @dropdownValues = []
        InputMapping.where.not(outbound: ['!', '|']).select("outbound").order("outbound").each do |t|
            @dropdownValues.push(t.outbound)
        end
        puts(@dropdownValues)

        if params[:problem_uid]
            id = String(params[:problem_uid])
            puts "UID:"+id
            @id = id
        else
            @id = "0"
        end
            
	end

 	def getPremises(problem_uid)
 		getProblemParts(problem_uid)[0]
 	end
 	helper_method :getPremises

	def getConclusion(problem_uid)
		getProblemParts(problem_uid)[1]
	end
	helper_method :getConclusion

 	def getProblemParts(problem_uid)
 		PracticeProblem.getPremisesAndConclusion(problem_uid)[0]
 	end
	# helper_method :getProblemParts

    def logic_problems

        problems = PracticeProblems.generate
        @problem = problems
        puts @problem.to_s

    end


    # TODO
    # - WHO IS DOING INPUT CHECKING???

    # ERROR TYPES
    # - Proof is not finished
    # - Premise is wrong
    # - Conclusion is wrong
    # - Incorrect usage of each individual rule
    # - Line numbers for use in proof are not correct (Can prove before send via assumption set calculation?)
    # - Assumption is made that isn't in premises and isn't resolved by the proof


    def calc_assumption_set(input_proof)
        length = input_proof.length
        assumption_set = Array.new(length)
        input_proof.each_with_index do |proof_line, index|
            dependent_lines = proof_line[1].split(',')
            if dependent_lines.nil? || dependent_lines.empty?
                if proof_line[2] == "A" 
                    assumption_set[index] = Array(index + 1)
                else
                    return
                end
            else
                # Use the lines used by the proof to find a valid assumption set
                assumption_set[index] = Array.new
                dependent_lines.each do |line|
                    line_num = line.to_i - 1
                    assumption_set[index].concat(assumption_set[line_num])
                end
                assumption_set[index] = assumption_set[index].uniq

                # Removes values from assumption set that match (#) syntax.
                exclusion_match = proof_line[2][/(?<=\()[\d]+(?=\))/].to_i
                if !exclusion_match.nil?
                    assumption_set[index].delete(exclusion_match)
                end
            end
        end
        return assumption_set
    end

    def parse_input(premises, conclusion, proof)
        puts proof
        #input_premesis_str = "p->r,r->q"
        #input_conclusion_str =  "p->q"
        #input_proof = [ [ "p->r", "", "A" ], [ "r->q", "", "A" ], [ "p", "", "A" ], [ "r", "1,3", "->E" ], [ "q", "2,4", "->E"], [ "p->q", "5", "->I(3)" ] ]
        input_premesis_str = premises
        input_conclusion_str = conclusion
        input_proof = []
        proof.values.each do |line|
            input_proof.push(line)
        end
        puts input_proof
        assumption_set = calc_assumption_set(input_proof)
        if assumption_set.nil?
                    data = {"reason"=>"Missing line numbers for non assumption proof line", "type"=>"error", "title"=>"Error","assumption_set"=>nil, "line_number"=>nil, "sentence"=>nil, "annotation"=>nil}
            return data
        end
        # Format output to logic.tamu.edu format
        formatted_proof = String.new
        input_proof.each_with_index do |line, index|
            formatted_proof << assumption_set[index].join(",") << " (" << (index + 1).to_s << ") " << line[0] << " " << line[1] << line[2] << "\r\n"
        end

        LatexMapping.all.each do |m|
            input_premesis_str.gsub! m.latex, m.mapping
            input_conclusion_str.gsub! m.latex, m.mapping
            formatted_proof.gsub! m.latex, m.mapping
        end

        InputMapping.all.each do |m|
            puts m
            input_premesis_str.gsub! m.outbound, m.mapping
            input_conclusion_str.gsub! m.outbound, m.mapping
            formatted_proof.gsub! m.outbound, m.mapping
        end

        puts formatted_proof
        result = post(input_premesis_str, input_conclusion_str, formatted_proof)
        puts result
        return result
    end

    def post(formatted_premesis, formatted_conclusion, formatted_proof)
        body_stage_1 = "------WebKitFormBoundaryPM7uJXvB7ekZjPLt\r\nContent-Disposition: form-data; name=\"premises\"\r\n\r\n"
        body_stage_2 = "\r\n------WebKitFormBoundaryPM7uJXvB7ekZjPLt\r\nContent-Disposition: form-data; name=\"conclusion\"\r\n\r\n"
        body_stage_3 = "\r\n------WebKitFormBoundaryPM7uJXvB7ekZjPLt\r\nContent-Disposition: form-data; name=\"bsubmit\"\r\n\r\nCheck Proof\r\n------WebKitFormBoundaryPM7uJXvB7ekZjPLt\r\nContent-Disposition: form-data; name=\"proof\"\r\n\r\n"
        body_stage_4 = "------WebKitFormBoundaryPM7uJXvB7ekZjPLt\r\nContent-Disposition: form-data; name=\"void\"\r\n\r\nRule : Annotation : Pattern\r\n------WebKitFormBoundaryPM7uJXvB7ekZjPLt--\r\n"



        curl = Curl::Easy.new("http://logic.tamu.edu/cgi-bin/logic.pl")
        curl.headers["Accept"] = "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8"
        curl.headers["Accept-Encoding"] = "gzip, deflate"
        curl.headers["Content-Type"] = "multipart/form-data; boundary=----WebKitFormBoundaryPM7uJXvB7ekZjPLt"
        curl.headers["DNT"] = "1"

        curl.encoding = 'gzip'
        curl.post_body = body_stage_1 + formatted_premesis + body_stage_2 + formatted_conclusion + body_stage_3 + formatted_proof + body_stage_4
        curl.http_post

        result_page = Nokogiri::HTML(curl.body_str)

        error_reason = result_page.xpath("//tr/td/p/img[@src='http://logic.tamu.edu/Images/th_up.gif']").last
        unless error_reason.nil?
            data = {"reason"=>"You did it!", "type"=>"success", "title"=>"Success", "assumption_set"=>nil, "line_number"=>nil, "sentence"=>nil, "annotation"=>nil}
            return data
        end

        # Parse errors. First maroon errors, then red ones, then traditional errors
        error_reason = result_page.xpath("//font[@color='maroon']").text
        unless error_reason.empty?
            error_reason = format_output(error_reason)
            data = {"reason"=>format_output(error_reason), "type"=>"error", "title"=>"Error","assumption_set"=>nil, "line_number"=>nil, "sentence"=>nil, "annotation"=>nil}
            return data
        end

        # Hey. This is probably going to crash if some new edge case shows. Heads up. Should probably fix this.
        error_reason = result_page.xpath("//font[@color='red']").first.parent.text
        unless error_reason.empty?
            puts "Red case"

            if error_reason == "'No conclusion.'"
                data = {"reason"=>"Please enter a conclusion", "type"=>"error", "title"=>"Error","assumption_set"=>nil, "line_number"=>nil, "sentence"=>nil, "annotation"=>nil}
                return data

            end
            is_error = result_page.xpath('//tr/td/p').last
            if is_error.nil?
                error_message = result_page.xpath('//body/center/font').last.text
            else 
                error_message = result_page.xpath('//tr/td/p').last.text
            end
            error_options = error_reason.split(/[[:space:]]+/)
            data = {"reason"=>format_output(error_message), "assumption_set"=>error_options[2], "type"=>"error", "title"=>"Error","line_number"=>error_options[3].scan(/\d+/).first, "sentence"=>error_options[4], "annotation"=>error_options[5]}
            puts "You failed. Reason: #{data["reason"]} Assumption Set: #{data["assumption_set"]}, Line Number: #{data["line_number"]}, Sentence: #{data["sentence"]}, Annotation: #{data["annotation"]}"
            return data
        end

        #NOTE This should never happen
        return "You missed an error."
    end

    def format_output(error_message)
        # Check each type of error from logic.tamu.edu and replace with our mappings
        ResponseMapping.all.each do |m|
            error_message.gsub! m.logic, m.mapping
        end
        return error_message
    end

end
