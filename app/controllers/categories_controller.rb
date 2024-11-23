class CategoriesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_category, only: [:show, :edit, :update, :destroy]
  after_action :verify_authorized, except: :index
  after_action :verify_policy_scoped, only: :index

  def index
    @q = policy_scope(Category).ransack(params[:q])
    @categories = @q.result
                   .includes(:assets)
                   .order(params[:sort] || 'name ASC')
                   .page(params[:page]).per(10)

    respond_to do |format|
      format.html
      format.csv { send_data @categories.to_csv, filename: "categories-#{Date.today}.csv" }
    end
  end

  def show
    authorize @category
    @assets = @category.assets.page(params[:page]).per(10)
  end

  def new
    @category = Category.new
    authorize @category
  end

  def edit
    @category = Category.find(params[:id])
    authorize @category
  end

  def create
    @category = Category.new(category_params)
    authorize @category

    if @category.save
      redirect_to @category, notice: 'Category was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    @category = Category.find(params[:id])
    authorize @category

    if @category.update(category_params)
      redirect_to @category, notice: 'Category was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @category
    if @category.assets.empty?
      @category.destroy
      redirect_to categories_url, notice: 'Category was successfully deleted.'
    else
      redirect_to categories_url, alert: 'Cannot delete category with associated assets.'
    end
  end

  private

  def set_category
    @category = Category.find(params[:id])
  end

  def category_params
    params.require(:category).permit(:name, :description, :parent_id)
  end
end 