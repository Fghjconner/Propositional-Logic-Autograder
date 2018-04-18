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
    		else
    			@response = "You have logic errors."
    		end
    	rescue => e
            @error = true

            @response = "You have syntax errors."
            @error_message = e.message + (e.line ? " | on line " + e.line.to_s : "")
            @line = e.formula
    	end
    end
end