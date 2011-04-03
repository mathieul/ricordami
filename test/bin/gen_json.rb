i = 1
strs = []
p.each do |pp|
  break if rand(100) == 99
  m.each do |mm|
    break if rand(5) == 0
    s = "    \"id\": \"r#{i}\",\n"
    i += 1
    s += "    \"person_id\": \"#{pp['id']}\",\n"
    s += "    \"movie_id\": \"#{mm['id']}\",\n"
    s += "    \"note\": #{rand(10) + 1},\n"
    s += "    \"when\": \"#{%w(matinee day evening).sample}\"\n"
    s += "  }, {\n"
    strs.push(s)
  end
end
strs.length

File.open("spec/data/review2.json", "w") { |f| f.write "[\n  {\n" + strs.join + "  }\n]\n" }
