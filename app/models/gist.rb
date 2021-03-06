class Gist < ApplicationRecord
  belongs_to :user
  belongs_to :question

  def register(params)
    self.question_id = params[:question_id] if params.key?(:question_id)
    self.url = params[:url]
    self.user_id = params[:user_id] if params.key?(:user_id)
    save!
  end
end
