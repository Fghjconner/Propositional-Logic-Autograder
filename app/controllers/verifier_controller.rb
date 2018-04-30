require "uri"
require "net/http"

class VerifierController < ApplicationController
    def index
    end
    
    def show
        @premise_prefill = params[:premise]
        @conclusion_prefill = params[:conclusion]
        @proof_prefill = params[:proof]


    	begin
            @error = false
    		if Engine.proof_valid?(params[:premise], params[:conclusion], params[:proof])
    			@response = "Correct!"
    		end
    	rescue => e
            @error = true

            @response = "Proof is not correct"
            @error_message = e.message + (e.line ? " | on line " + e.line.to_s : "")
            @line = e.formula
    	end
    end
end