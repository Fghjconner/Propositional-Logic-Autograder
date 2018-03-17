class EntriesController < ApplicationController
	def show
		@entry = Entry.find(params[:id])
	end

	def new
	end

	def create
		@entry = Entry.new(entry_params)

		@entry.save
		redirect_to @entry
	end

	private
		def entry_params
			params.require(:entry).permit(:premise, :conclusion, :proof)
		end
end
