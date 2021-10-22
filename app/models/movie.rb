class Movie < ActiveRecord::Base
  
  #define instance variable of all_ratings that view can us
  #where all_ratings = empty array

  @ratings_to_show = []
  #@all_ratings = ['G','PG','PG-13','R']
  @all_ratings = Movie.distinct.pluck(:rating)
  
  def self.all_ratings()
    @all_ratings
  end
  
  def self.ratings_to_show(ratings_list)
    if(ratings_list.blank?())
      #if first time accessing page, make sure to check all boxes
      #THIS COULD BE PROBLEMATIC, GET ALL RATINGS FROM ACTIVE RECORD NOT HARD CODED
      #solved: use model.distinct.pluck(:rating)
      #@ratings_to_show = ['G','PG','PG-13','R']
      @ratings_to_show = Movie.distinct.pluck(:rating)
    else
      #return ratings to show where only in keys of ratings_list
      @ratings_to_show = ratings_list.keys
    end
  end
  
  def self.with_ratings(ratings_list) 
  # if ratings_list is an array such as ['G', 'PG', 'R'], retrieve all
  #  movies with those ratings
  # if ratings_list is nil, retrieve ALL movies

    if(ratings_list.blank?()) 
      #return all movies if ratings_list is nil
      return Movie.all

    else
      #return only movies in ratings_list.keys since it is non-empty
      return Movie.where(rating: ratings_list.keys)

    end
    
  end
      
end
