module Api
  module V1
    class TasksController < ApplicationController
      before_action :set_project
      before_action :set_task, only: %i[show update destroy complete suggest_subtasks]

      # GET /api/v1/projects/:project_id/tasks
      def index
        tasks = @project.tasks
        tasks = tasks.where(status: params[:status]) if params[:status].present?
        tasks = tasks.overdue if params[:overdue] == "true"
        tasks = tasks.ordered.page(params[:page]).per(params[:per_page] || 50)

        render json: TaskSerializer.new(tasks).serializable_hash, status: :ok
      end

      # GET /api/v1/projects/:project_id/tasks/:id
      def show
        render json: TaskSerializer.new(@task).serializable_hash, status: :ok
      end

      # POST /api/v1/projects/:project_id/tasks
      def create
        task = @project.tasks.new(task_params)
        if task.save
          render json: TaskSerializer.new(task).serializable_hash, status: :created
        else
          render json: { errors: task.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # PATCH/PUT /api/v1/projects/:project_id/tasks/:id
      def update
        if @task.update(task_params)
          render json: TaskSerializer.new(@task).serializable_hash, status: :ok
        else
          render json: { errors: @task.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/projects/:project_id/tasks/:id
      def destroy
        @task.destroy
        head :no_content
      end

      # POST /api/v1/projects/:project_id/tasks/:id/complete
      def complete
        result = Tasks::CompleteTask.call(@task)

        if result.success?
          render json: TaskSerializer.new(result.task).serializable_hash, status: :ok
        else
          render json: { error: result.error }, status: :unprocessable_entity
        end
      end

      # POST /api/v1/projects/:project_id/tasks/:id/suggest_subtasks
      # Asks Claude to break the task down into suggested subtasks.
      def suggest_subtasks
        result = Tasks::SuggestSubtasks.call(@task)

        if result.success?
          render json: { task_id: @task.id, suggestions: result.subtasks }, status: :ok
        else
          render json: { error: result.error }, status: :bad_gateway
        end
      end

      private

      def set_project
        @project = Project.find(params[:project_id])
      end

      def set_task
        @task = @project.tasks.find(params[:id])
      end

      def task_params
        params.permit(:title, :description, :status, :priority, :due_date, :position)
      end
    end
  end
end
