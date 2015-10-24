json.extract! @member, :id, :name, :member_type, :start_date, :end_date, :dob, :bio, :created_at, :updated_at
json.statements @member.statements, :id, :url, :summary, :lean, :pub_date, :statement_date, :similar_to_prior, :created_at, :updated_at
