class Statement < ActiveRecord::Base
  belongs_to :member

  scope :exclude_non_voting, ->(nonvoting) do
    unless nonvoting.nil? || nonvoting.blank?
      joins('JOIN terms on terms.member_id = statements.member_id').where('(statements.statement_date BETWEEN terms.start_date AND terms.end_date) OR (statements.statement_date >= terms.start_date AND terms.end_date IS NULL)')
    else
      all
    end
  end

  scope :exclude_similar_to_prior, ->(similar) do
    unless similar.nil? || similar.blank?
      where("similar_to_prior = ?", false)
    else
      all
    end
  end

  scope :exclude_non_voting_as_of_now, ->(nonvoting) do
    unless nonvoting.nil? || nonvoting.blank?
      joins('JOIN terms on terms.member_id = statements.member_id').where('(now()::date BETWEEN terms.start_date AND terms.end_date) OR (now()::date >= terms.start_date AND terms.end_date IS NULL)')
    else
      all
    end
  end

end
