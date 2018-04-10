require 'rails_helper'

RSpec.describe StaticController, type: :controller do

  describe "GET #quiz" do
    it "returns http success" do
      get :quiz
      expect(response).to have_http_status(:success)
    end
  end

end
