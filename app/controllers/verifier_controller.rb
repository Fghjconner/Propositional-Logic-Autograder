require "uri"
require "net/http"

class VerifierController < ApplicationController
    def index
    end
    
    def show
    	begin
    		if Engine.proof_valid?(params[:premise], params[:conclusion], params[:proof])
    			@response = "Good"
    		else
    			@response = "Bad"
    		end
    	rescue
    		@response = "Invalid Entry"
    	end
    end
end