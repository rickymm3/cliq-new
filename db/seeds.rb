User.create!([
  {email: "rickymm3@gmail.com", password: "password123", reset_password_token: nil, reset_password_sent_at: nil, remember_created_at: nil, username: "Rickymm3"}
])
Profile.create!([
  {user_id: 1, username: "ricky"}
])
Cliq.create!([
  {name: "Cliq", description: nil, parent_cliq_id: nil, slug: "cliq"},
  {name: "Entertainment", description: "All your entertainment needs here.  Drill down to discuss specific interests!", parent_cliq_id: 1, slug: "entertainment"},
  {name: "Science", description: nil, parent_cliq_id: 1, slug: "science"},
  {name: "Gaming", description: nil, parent_cliq_id: 1, slug: "gaming"},
  {name: "Politics", description: nil, parent_cliq_id: 1, slug: "politics"},
])

Post.create!([
])

