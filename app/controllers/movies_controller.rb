class MoviesController < ApplicationController
  
  #before_action :get_movie_from_session
  #after_action :store_movie_in_session

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end
 
  def index
    #POSSIBLE ISSUE: REFRESH DOES NOT INCLUDE SORT=TITLE/RELEASE_DATE, COULD BE NON-RESTFUL???
    #SOLVED: should be good because sort=title/release is inside uri from refresh now, except could be in wrong spot?
    
    #check if params sorting / filtering is empty
    #set params[:home] = 1 and check in redirects?
   
    '''
    puts "IN THE BEGINNING ---------------------------"
    puts "params sorting: " + params[:sort].to_s
    puts "params filtering: " + params[:ratings].to_s
    puts "session sorting: " + session[:sort].to_s
    puts "session filtering: " + session[:ratings].to_s
    puts "home: " + params[:home].to_s
    puts "----------------------------------------------"
    '''
    
    #debugging prints
    #puts "session sort: " + session[:sort].to_s    

    #if params has no sort option but session remembered a sort option, set that option for column_clicked
    #for refresh button to remember which should be highlighted
    if (params[:sort].blank? && !session[:sort].blank?)
      @column_clicked = session[:sort]
    else 
      @column_clicked = params[:sort]
      session[:sort] = params[:sort]
    end
    '''
    #debugging prints
    puts "column clicked assigned: " + @column_clicked.to_s
    puts "session sort is now: " + session[:sort].to_s
    
    puts "session ratings: " + session[:ratings].to_s
    puts "params ratings: " + params[:ratings].to_s
    '''
    #same procedure as above: if params has no ratings option but session does, set that option for ratings_list
    #to be used to grab ratings_to_show
    if(params[:ratings].blank? && !session[:ratings].blank?)
      #if params sort exists, it is because form tag hidden field passed it back 
      #means that i submitted some checkboxes - all checkboxes are now empty so give all ratings
      if (!params[:sort].blank?)
        ratings_list = Movie.all_ratings().to_h { |x| [x, 1]}
      else
        #did not submit any check boxes and we are coming back to home page - keep session ratings
        ratings_list = session[:ratings]
      end
        
      session[:ratings] = ratings_list
      
    else 
      ratings_list = params[:ratings]
      session[:ratings] = params[:ratings]
    end
    
    #debugging prints
    #puts "ratings list is now: " + ratings_list.to_s

    @all_ratings = Movie.all_ratings()
    @ratings_to_show = Movie.ratings_to_show(ratings_list)
    @movies = Movie.with_ratings(ratings_list).order(@column_clicked)
    
    '''
    #ratings and column clicked to display
    puts "IN THE END ---------------------"
    puts "ratings to show: " + @ratings_to_show.to_s
    puts "column clicked: " + @column_clicked.to_s
    puts "---------------------------------"
    '''
    
  end
  
  '''
  def store_movie_in_session
    session[:movies] = @movies
    session[:ratings_to_show] = @ratings_to_show
    session[:sort] = params[:sort]
  end

  def get_movie_from_session
    @movies = session[:movies]
    @ratings_to_show = session[:ratings]
  end
  '''

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    #redirect_to movies_path
    redirect_to movies_path({:sort => session[:sort], :ratings => session[:ratings]})
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    #redirect_to movies_path
    #redirect_to movies_path({:sort => @column_clicked, :ratings => @ratings_to_show.to_h { |x| [x, 1]}})
    redirect_to movies_path({:sort => session[:sort], :ratings => session[:ratings]})
  end

  private
  # Making "internal" methods private is not required, but is a common practice.
  # This helps make clear which methods respond to requests, and which ones do not.
  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end
end
