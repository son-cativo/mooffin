class RecipesController < ApplicationController
	before_action :get_recipe, only: [:show, :edit, :destroy]
	before_action :get_reasons, only: [:show]
	wrap_parameters format: [:json, :xml]

	logger = Log4r::Logger.new('recipes_controller_debug')

	def get_reasons
		@reasons = Reason.all
	end

	def get_recipe
		@recipe = Recipe.friendly.find(params[:id])
	end

	def new
		@recipe = Recipe.new
		@link = Link.new
	end

	def show
		@opinion = Opinion.new
		@like = Like.new
		@opinions = @recipe.opinions
		@recipe.increment!(:views_count, by = 1)	#-Contador de visitas
	end

	def index
		@recipes = Recipe.all
		respond_to do |format|
			format.json {
				render json: @recipes
			}
			format.html {
				@recipes
			}
  		end
	end

	def proposals
		idsIngredients = []
		idsIngredients = proposals_params
		@proposals = Recipe.find_proposals(idsIngredients)
		respond_to do |format|
			format.json {
				render json: @proposals.to_json(:methods => [:photo_url])
			}
			format.html {
				@proposals
			}
  		end
	end

	def getLastRecipes
		@ultimasRecetas = Recipe.last(4).reverse
		respond_to do |format|
			format.json {
				render json: @ultimasRecetas.to_json(:methods => [:photo_url])
			}
			format.html {
				@ultimasRecetas
			}
		end
	end

	def edit
	end

	def update
		@recipe = current_user.recipes.update(params[:id], recipe_update_params)
		render :nothing => true, :status => 202
	end

	def destroy
		@recipe.destroy
		Recipe.update_sitemap
	end

	def create
		@recipe = current_user.recipes.new(recipe_params)
		respond_to do |format|
			if @recipe.save
				Recipe.update_sitemap
				format.html { redirect_to "/usuarios/#{current_user.id}", notice: 'Receta creada!' }
			else
				format.html { redirect_to new_recipe_path, :notice => "Error al crear la receta!" }
			end
		end
	end

	def appauth
		head 200, content_type: "text/html"
	end

	private
		def recipe_params
			params.require(:recipe).permit(:recipe, :description, :title, :time,
				:source, :url_source,
				:servings, :difficulty_id, :course_id,
				:photo, steps_attributes: [:orden, :description],
				links_attributes: [:ingredient_id, :importance_id, :text_link])
				# ,
				# recipecats_attributes: [:recipe_id, :category_id])
		end

		def recipe_update_params
			params.require(:recipe).permit(:recipe, :description, :title, :time,
				:source, :url_source,
				:servings, :difficulty_id, :course_id,
				:photo, steps_attributes: [:id, :orden, :description, :_destroy],
				links_attributes: [:id, :ingredient_id, :importance_id, :text_link, :_destroy])
				# ,
				# recipecats_attributes: [:recipe_id, :category_id]
		end

		def proposals_params
			params.require(:idsIngredients)
		end

end
