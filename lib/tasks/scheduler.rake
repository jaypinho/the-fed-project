desc "This task adds the daily federal funds rate to the database"
task :grab_daily_fed_funds_rate => :environment do

  x = Net::HTTP.get_response(URI("https://api.stlouisfed.org/fred/series/observations?series_id=DFF&sort_order=desc&limit=1&api_key=#{ENV['FEDERAL_RESERVE_API_KEY']}&file_type=json"))

  if x.code == '200' && JSON.parse(x.body).has_key?('observations') && KeyRate.where(:rate_date => JSON.parse(x.body)['observations'][0]['date']).count == 0

    y = KeyRate.new :rate_date => JSON.parse(x.body)['observations'][0]['date'],
                    :actual_rate => JSON.parse(x.body)['observations'][0]['value']
    y.save

  end

end
