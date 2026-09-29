require "rails_helper"

RSpec.describe "Api::V1::ReferenceData", type: :request do
  it "returns countries, departments, and job_levels" do
    create(:country, name: "United States")
    create(:department, name: "Engineering")
    create(:job_level, name: "Senior", rank: 3)

    get "/api/v1/reference_data"

    json = JSON.parse(response.body)
    expect(response).to have_http_status(:ok)
    expect(json["countries"].map { |c| c["name"] }).to include("United States")
    expect(json["departments"].map { |d| d["name"] }).to include("Engineering")
    expect(json["job_levels"].map { |l| l["name"] }).to include("Senior")
  end
end
