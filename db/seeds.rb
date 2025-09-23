# db/seeds.rb
# Generates ~100 cliqs and 1,000 posts with ActionText content.

require "securerandom"

puts "Seeding users/profiles…"

users = [
  { email: "rickymm3@gmail.com",  username: "rickymm3"  },
  { email: "rickymm32@gmail.com", username: "rickymm32" },
  { email: "rickymm33@gmail.com", username: "rickymm33" }
].map do |attrs|
  user = User.find_or_create_by!(email: attrs[:email]) do |u|
    # random password for seeds; devise requires something
    u.password = "password-#{SecureRandom.hex(4)}"
  end
  Profile.find_or_create_by!(user_id: user.id) do |p|
    p.username = attrs[:username]
  end
  user
end

def slug_for(parent, name)
  return "cliq" if parent.nil?
  "#{parent.id}-#{name.parameterize}"
end

def create_cliq!(name:, parent:, description: nil)
  cliq = Cliq.find_or_initialize_by(name: name, parent_cliq_id: parent&.id)
  cliq.description = description if description && cliq.description.blank?
  cliq.slug = slug_for(parent, name) if cliq.slug.blank?
  cliq.save!
  cliq
end

puts "Ensuring root cliq…"
root = Cliq.find_or_create_by!(name: "Cliq", parent_cliq_id: nil) do |c|
  c.description = "Every single topic on the site exists here - Find a topic you’re interested in and jump right in!"
  c.slug = "cliq"
end

# -------------------------
# Category → Subcategory → Leaf topics (trimmed to ~5 leaves each to total ~100 cliqs)
# -------------------------

DATA_TREE = {
  "Entertainment" => {
    "TV Shows" => [
      "Breaking Bad", "Stranger Things", "Game of Thrones", "The Bear", "The Sopranos"
    ],
    "Movies" => [
      "Marvel Cinematic Universe", "Star Wars", "Christopher Nolan", "A24", "Pixar"
    ],
    "Music" => [
      "Hip-Hop", "Pop", "Rock", "K-Pop", "Jazz"
    ],
    "Celebrities" => [
      "Taylor Swift", "Beyoncé", "Zendaya", "Keanu Reeves", "Pedro Pascal"
    ]
  },
  "Science" => {
    "Astronomy" => [
      "Exoplanets", "Black Holes", "James Webb Space Telescope", "Cosmology", "Astrobiology"
    ],
    "Biology" => [
      "Genetics", "CRISPR", "Neuroscience", "Microbiome", "Evolution"
    ],
    "Earth Science" => [
      "Climate Change", "Geology", "Volcanoes", "Earthquakes", "Oceans"
    ],
    "Tech & AI" => [
      "Machine Learning", "Large Language Models", "Robotics", "Quantum Computing", "Cybersecurity"
    ]
  },
  "Gaming" => {
    "Platforms" => [
      "PC Gaming", "PlayStation", "Xbox", "Nintendo Switch", "VR Gaming"
    ],
    "Genres" => [
      "Soulslikes", "RPGs", "FPS", "Strategy", "Roguelikes"
    ],
    "Franchises" => [
      "Zelda", "Elden Ring", "Hollow Knight", "Minecraft", "GTA"
    ],
    "Esports" => [
      "League of Legends Esports", "Dota 2", "CS2", "Valorant", "Rocket League"
    ]
  },
  "Politics" => {
    "US Politics" => [
      "Elections", "Supreme Court", "Congress", "White House", "Polling"
    ],
    "World Politics" => [
      "Europe", "Middle East", "Asia-Pacific", "Africa", "Latin America"
    ],
    "Issues" => [
      "Healthcare", "Immigration", "Economy", "Education", "Climate Policy"
    ]
  }
}

puts "Creating cliq hierarchy (~100 cliqs)…"

main_nodes     = []
subcategory_nodes = []
leaf_nodes     = []

ActiveRecord::Base.transaction do
  DATA_TREE.each do |main_name, subcats|
    main = create_cliq!(name: main_name, parent: root, description: nil)
    main_nodes << main

    subcats.each do |subcat_name, leaves|
      sub = create_cliq!(name: subcat_name, parent: main)
      subcategory_nodes << sub

      leaves.each do |leaf_name|
        leaf = create_cliq!(name: leaf_name, parent: sub)
        leaf_nodes << leaf
      end
    end
  end
end

puts "Created/ensured: #{[root, *main_nodes, *subcategory_nodes, *leaf_nodes].uniq.count} cliqs"
puts "Leaf topics: #{leaf_nodes.count}"

# -------------------------
# Generate 1,000 Posts spread across leaf topics
# -------------------------

def title_templates_for(leaf_name)
  base = leaf_name
  [
    "#{base}: General Discussion",
    "#{base} – News & Updates",
    "Favorite Moments in #{base}",
    "#{base} Q&A Thread",
    "#{base} Beginners’ Guide",
    "Hot Takes: #{base}",
    "Predictions for #{base}",
    "#{base} — Tips & Tricks",
    "Weekly Thread: #{base}",
    "Is #{base} over/underrated?"
  ]
end

def random_paragraphs_for(leaf_name)
  [
    "<p>Let’s talk about <strong>#{leaf_name}</strong>. What’s new and what are you enjoying lately?</p>",
    "<p>Share resources, links, and your own insights. Be kind; debate ideas, not people.</p>",
    "<p>Use spoiler tags where needed and report spam. Have fun!</p>"
  ].join
end

posts_to_create = 1000
puts "Generating #{posts_to_create} posts…"

created = 0
ActiveRecord::Base.transaction do
  posts_to_create.times do
    leaf   = leaf_nodes.sample
    author = users.sample

    tmpl   = title_templates_for(leaf.name).sample
    # add a little variance to keep many unique titles
    title  = "#{tmpl} ##{SecureRandom.random_number(10_000)}"

    post = Post.create!(
      title:  title,
      cliq_id: leaf.id,
      user_id: author.id,
      deleted: false
      # slug: (let your model generate; if you must set, add a parameterized version of title)
    )

    # ActionText content
    post.content = random_paragraphs_for(leaf.name)
    post.save!

    created += 1
  end
end

puts "Created #{created} posts."

puts "Done."
