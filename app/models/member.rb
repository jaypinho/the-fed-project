class Member < ActiveRecord::Base
  has_many :statements
  has_many :terms

  scope :only_include_current_voters, ->(voting) do
    unless voting.nil? || voting.blank?
      joins(:terms).where('(now()::date BETWEEN terms.start_date AND terms.end_date) OR (now()::date >= terms.start_date AND terms.end_date IS NULL)')
    else
      all
    end
  end

end
