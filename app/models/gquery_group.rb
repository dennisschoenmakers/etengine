class GqueryGroup < ActiveRecord::Base
  has_and_belongs_to_many :gqueries
end

# == Schema Information
#
# Table name: gquery_groups
#
#  id          :integer(4)      not null, primary key
#  group_key   :string(255)
#  created_at  :datetime
#  updated_at  :datetime
#  description :text
#
