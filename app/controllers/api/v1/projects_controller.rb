module Api
  module V1
    class ProjectsController < ApplicationController
      before_action :set_project, only: %i[show update destroy progress]

      # GET /api/v1/projects
      def index
        projects = Project.includes(:tasks)
        projects = projects.where(user_id: params[:user_id]) if params[:user_id].present?
        projects = projects.order(created_at: :desc).page(params[:page]).per(params[:per_page] || 25)

        render json: ProjectSerializer.new(projects).serializable_hash, status: :ok
      end

      # GET /api/v1/projects/:id
      def show
        render json: ProjectSerializer.new(@project).serializable_hash, status: :ok
      end

      # POST /api/v1/projects
      def create
        project = Project.new(project_params)
        if project.save
          render json: ProjectSerializer.new(project).serializable_hash, status: :created
        else
          render json: { errors: project.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # PATCH/PUT /api/v1/projects/:id
      def update
        if @project.update(project_params)
          render json: ProjectSerializer.new(@project).serializable_hash, status: :ok
        else
          render json: { errors: @project.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/projects/:id
      def destroy
        @project.destroy
        head :no_content
      end

      # GET /api/v1/projects/:id/progress
      def progress
        calculator = Projects::ProgressCalculator.new(@project)
        render json: {
          project_id: @project.id,
          percentage: calculator.percentage,
          total: calculator.total,
          done: calculator.done_count,
          counts_by_status: calculator.counts_by_status,
          completed: @project.completed?
        }, status: :ok
      end

      private

      def set_project
        @project = Project.find(params[:id])
      end

      def project_params
        params.permit(:name, :description, :user_id)
      end
    end
  end
end
