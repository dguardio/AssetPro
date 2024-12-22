module Api
  module V1
    class CategoriesController < BaseController
      before_action :set_category, only: [:show, :update, :destroy]

      def index
        @categories = policy_scope(Category)
        @categories = params[:show_deleted] ? @categories.with_deleted : @categories
        @categories = @categories.includes(:parent)
                               .order(name: :asc)
                               .page(params[:page])

        render json: {
          categories: ActiveModel::SerializableResource.new(@categories, each_serializer: CategorySerializer),
          meta: {
            total_count: @categories.total_count,
            current_page: @categories.current_page,
            total_pages: @categories.total_pages,
            per_page: @categories.limit_value
          }
        }
      end

      def show
        render json: @category, 
               serializer: CategorySerializer,
               include: ['parent'],
               meta: {
                 asset_count: @category.assets.count
               }
      end

      def create
        @category = Category.new(category_params)
        authorize @category

        if @category.save
          render json: @category, status: :created, serializer: CategorySerializer
        else
          render json: { errors: @category.errors }, status: :unprocessable_entity
        end
      end

      def update
        authorize @category
        
        if @category.update(category_params)
          render json: @category, serializer: CategorySerializer
        else
          render json: { errors: @category.errors }, status: :unprocessable_entity
        end
      end

      def destroy
        authorize @category
        
        if @category.assets.empty? && @category.destroy
          head :no_content
        else
          render json: { 
            errors: ['Cannot delete category with associated assets'] 
          }, status: :unprocessable_entity
        end
      end

      private

      def set_category
        @category = Category.find(params[:id])
        authorize @category
      end

      def category_params
        params.require(:category).permit(:name, :description, :parent_id)
      end
    end
  end
end 