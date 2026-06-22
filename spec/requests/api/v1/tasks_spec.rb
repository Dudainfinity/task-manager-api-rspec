require 'rails_helper'

RSpec.describe 'Api::V1::Tasks', type: :request do
  let(:project) { create(:project) }

  describe 'GET /api/v1/projects/:project_id/tasks' do
    it 'lists tasks ordered by position' do
      create_list(:task, 3, project: project)
      get "/api/v1/projects/#{project.id}/tasks"
      expect(response).to have_http_status(:ok)
      expect(response.parsed_body['data'].size).to eq(3)
    end

    it 'filters by status' do
      create(:task, :done, project: project)
      create(:task, project: project)
      get "/api/v1/projects/#{project.id}/tasks", params: { status: 'done' }
      expect(response.parsed_body['data'].size).to eq(1)
    end

    it 'filters overdue tasks' do
      create(:task, :overdue, project: project)
      create(:task, project: project)
      get "/api/v1/projects/#{project.id}/tasks", params: { overdue: 'true' }
      expect(response.parsed_body['data'].size).to eq(1)
    end
  end

  describe 'GET /api/v1/projects/:project_id/tasks/:id' do
    it 'returns the task' do
      task = create(:task, project: project)
      get "/api/v1/projects/#{project.id}/tasks/#{task.id}"
      expect(response).to have_http_status(:ok)
      expect(response.parsed_body.dig('data', 'attributes', 'title')).to eq(task.title)
    end

    it 'returns 404 when the task is not in the project' do
      other = create(:task)
      get "/api/v1/projects/#{project.id}/tasks/#{other.id}"
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'POST /api/v1/projects/:project_id/tasks' do
    it 'creates a task' do
      expect do
        post "/api/v1/projects/#{project.id}/tasks", params: { title: 'Implementar login', priority: 'high' }
      end.to change(project.tasks, :count).by(1)
      expect(response).to have_http_status(:created)
    end

    it 'returns errors with invalid data' do
      post "/api/v1/projects/#{project.id}/tasks", params: { title: '' }
      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.parsed_body['errors']).to be_present
    end
  end

  describe 'PATCH /api/v1/projects/:project_id/tasks/:id' do
    it 'updates the task' do
      task = create(:task, project: project)
      patch "/api/v1/projects/#{project.id}/tasks/#{task.id}", params: { status: 'in_progress' }
      expect(response).to have_http_status(:ok)
      expect(task.reload).to be_in_progress
    end

    it 'returns errors with invalid data' do
      task = create(:task, project: project)
      patch "/api/v1/projects/#{project.id}/tasks/#{task.id}", params: { title: '' }
      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.parsed_body['errors']).to be_present
    end
  end

  describe 'DELETE /api/v1/projects/:project_id/tasks/:id' do
    it 'deletes the task' do
      task = create(:task, project: project)
      expect do
        delete "/api/v1/projects/#{project.id}/tasks/#{task.id}"
      end.to change(Task, :count).by(-1)
      expect(response).to have_http_status(:no_content)
    end
  end

  describe 'POST /api/v1/projects/:project_id/tasks/:id/complete' do
    it 'completes a pending task' do
      task = create(:task, project: project)
      post "/api/v1/projects/#{project.id}/tasks/#{task.id}/complete"
      expect(response).to have_http_status(:ok)
      expect(task.reload).to be_done
      expect(response.parsed_body.dig('data', 'attributes', 'status')).to eq('done')
    end

    it 'returns 422 when the task is already done' do
      task = create(:task, :done, project: project)
      post "/api/v1/projects/#{project.id}/tasks/#{task.id}/complete"
      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.parsed_body['error']).to eq('Task is already done')
    end
  end

  describe 'POST /api/v1/projects/:project_id/tasks/:id/suggest_subtasks' do
    let(:task) { create(:task, project: project) }

    it 'returns the AI-suggested subtasks' do
      result = Tasks::SuggestSubtasks::Result.new(
        success: true,
        subtasks: [ { title: 'Write the migration', priority: 'high' } ],
        error: nil
      )
      allow(Tasks::SuggestSubtasks).to receive(:call).with(an_instance_of(Task)).and_return(result)

      post "/api/v1/projects/#{project.id}/tasks/#{task.id}/suggest_subtasks"

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body['task_id']).to eq(task.id)
      expect(response.parsed_body['suggestions']).to eq([ { 'title' => 'Write the migration', 'priority' => 'high' } ])
    end

    it 'returns 502 when the AI provider fails' do
      result = Tasks::SuggestSubtasks::Result.new(success: false, subtasks: [], error: 'rate limited')
      allow(Tasks::SuggestSubtasks).to receive(:call).and_return(result)

      post "/api/v1/projects/#{project.id}/tasks/#{task.id}/suggest_subtasks"

      expect(response).to have_http_status(:bad_gateway)
      expect(response.parsed_body['error']).to eq('rate limited')
    end
  end
end
