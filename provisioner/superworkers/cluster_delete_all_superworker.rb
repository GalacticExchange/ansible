=begin
Superworker.define(:MySuperworker, :user_id, :comment_id) do
  Worker1 :user_id, :comment_id
  Worker2 :comment_id
end
=end
