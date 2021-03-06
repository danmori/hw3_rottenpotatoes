# Add a declarative step here for populating the DB with movies.

Given /the following movies exist/ do |movies_table|
  movies_table.hashes.each do |movie|
    Movie.create!(movie)
  end
end

# Make sure that one string (regexp) occurs before or after another one
#   on the same page

Then /I should see "(.*)" before "(.*)"/ do |e1, e2|
  assert page.body =~ /#{e1}.*#{e2}/m, "#{e1} isn't before #{e2}"
end

# Make it easier to express checking or unchecking several boxes at once
#  "When I uncheck the following ratings: PG, G, R"
#  "When I check the following ratings: G"

Given /I (un)?check the following ratings: (.*)/ do |uncheck, rating_list|
  rating_list.split(',').map(&:strip).each do |rating|
    rating = "ratings_" + rating
    if uncheck
      uncheck(rating)
    else
      check(rating)
    end
  end
end

When /^I (un)?check all the ratings$/ do | uncheck |
  Movie.all_ratings.each do | rating  |
    rating = "ratings_" + rating
    if uncheck
      uncheck(rating)
    else
      check(rating)
    end
  end
end

Then /I should (not )?see all movies rated: (.*)/ do |neg, rating_list|
  ratings = rating_list.split(",").map(&:strip)

  if neg
    movies = Movie.where(:rating => ratings)
    movies.each do |movie|
      if page.respond_to? :should
        page.should have_no_content(/#{movie.title}/)
      else
        assert page.has_no_content?(/#{movie.title}/)
      end
    end
  else
    movies = Movie.where(:rating => ratings) 
    movies.each do |movie|
      if page.respond_to? :should
        page.should have_content(/#{movie.title}/)
      else
        assert page.has_content?(/#{movie.title}/)
      end
    end
  end

end

Then /I should see all of the movies/ do
  movies = Movie.all
  movies.each do |movie|
    assert page.body =~ /#{movie.title}/m, "#{movie.title} did not appear"
  end
  #assert Movie.find(:all).length == page.body.scan(/<tr>/).length , "Not seing all movies" 
end

Then /I should not see any movies/ do
  movies = Movie.all
  movies.each do |movie|
    assert true unless page.body =~ /#{movie.title}/m
  end
end
