require "uri"
require "net/http"

class VerifierController < ApplicationController
    def index
    end
    
    def show
    	begin
    		if Engine.proof_valid?(params[:premise], params[:conclusion], params[:proof])
    			@response = "Correct!"
    		else
    			@response = "You have logic errors."
    		end
    	rescue => e
            @response = "You have syntax errors."
            @wut = e.message + " | Line no: " 
    	end
    end
end