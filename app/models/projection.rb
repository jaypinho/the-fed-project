class Projection < ActiveRecord::Base

  def self.read_events

    require 'open-uri'
    require 'net/http'
    require 'csv'

    uri = URI("http://jaypinho.com/fedfunds.csv")
    csv_text = Net::HTTP.get(uri)
    csv = CSV.parse(csv_text)
    csv.each do |row|
      KeyRate.create(:present_date => row[0].to_date, :actual_rate => row[1].to_d)
    end
  end

end
