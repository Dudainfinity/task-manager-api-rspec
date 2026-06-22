require 'rails_helper'

RSpec.describe 'Api::V1::Projects', type: :request do
  let(:user) { create(:user) }

  describe 'GET /api/v1/projects' do
    it 'returns all projects' do
      create_list(:project, 3)
      get '/api/v1/projects'
      expect(response).to have_http_status(:ok)
      expect(response.parsed_body['data'].size).to eq(3)
    end

    it 'filters by user_id' do
      create(:project, user: user)
      create(:project)
      get '/api/v1/projects', params: { user_id: user.id }
      expect(response.parsed_body['data'].size).to eq(1)
    end
  end

  describe 'GET /api/v1/projects/:id' do
    it 'returns the project with progress' do
      project = create(:project)
      create(:task, :done, project: project)
      get "/api/v1/projects/#{project.id}"
      expect(response).to have_http_status(:ok)
      expect(response.parsed_body.dig('data', 'attributes', 'progress')).to eq(100)
    end

    it 'returns 404 for a missing project' do
      get '/api/v1/projects/0'
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'POST /api/v1/projects' do
    it 'creates a project with valid params' do
      expect do
        post '/api/v1/projects', params: { name: 'Novo Projeto', user_id: user.id }
      end.to change(Project, :count).by(1)
      expect(response).to have_http_status(:created)
    end

    it 'returns errors with invalid params' do
      post '/api/v1/projects', params: { name: '', user_id: user.id }
      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.parsed_body['errors']).to be_present
    end
  end

  describe 'PATCH /api/v1/projects/:id' do
    it 'updates the project' do
      project = create(:project, name: 'Antigo')
      patch "/api/v1/projects/#{project.id}", params: { name: 'Atualizado' }
      expect(response).to have_http_status(:ok)
      expect(project.reload.name).to eq('Atualizado')
    end

    it 'returns errors with invalid data' do
      project = create(:project)
      patch "/api/v1/projects/#{project.id}", params: { name: '' }
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe 'DELETE /api/v1/projects/:id' do
    it 'deletes the project and its tasks' do
      project = create(:project)
      create(:task, project: project)
      expect do
        delete "/api/v1/projects/#{project.id}"
      end.to change(Project, :count).by(-1).and change(Task, :count).by(-1)
      expect(response).to have_http_status(:no_content)
    end
  end

  describe 'GET /api/v1/projects/:id/progress' do
    it 'returns the progress breakdown' do
      project = create(:project)
      create(:task, :done, project: project)
      create(:task, :in_progress, project: project)

      get "/api/v1/projects/#{project.id}/progress"
      expect(response).to have_http_status(:ok)
      body = response.parsed_body
      expect(body['percentage']).to eq(50)
      expect(body['total']).to eq(2)
      expect(body['done']).to eq(1)
      expect(body['counts_by_status']).to eq('todo' => 0, 'in_progress' => 1, 'done' => 1)
    end
  end
end
