# Dados de exemplo (seed) da API de gerenciamento de tarefas.
# Rode com: bin/rails db:seed   (ou db:setup para criar + migrar + popular)

puts "Cleaning database..."
Task.delete_all
Project.delete_all
User.delete_all

puts "Creating user..."
user = User.create!(name: "Maria Dev", email: "maria@example.com")

puts "Creating projects and tasks..."
api = user.projects.create!(name: "API de Pagamentos", description: "Integração com gateway")
api.tasks.create!(title: "Modelar transações", status: :done, priority: :high, completed_at: Time.current)
api.tasks.create!(title: "Endpoint de cobrança", status: :in_progress, priority: :high, due_date: Date.current + 3)
api.tasks.create!(title: "Webhook de confirmação", status: :todo, priority: :medium, due_date: Date.current + 7)
api.tasks.create!(title: "Documentar API", status: :todo, priority: :low, due_date: Date.current - 1)

site = user.projects.create!(name: "Site Institucional", description: "Landing page e blog")
site.tasks.create!(title: "Design da home", status: :done, priority: :medium, completed_at: Time.current)
site.tasks.create!(title: "Implementar blog", status: :todo, priority: :medium, due_date: Date.current + 10)

puts "Done!"
puts "  Users:    #{User.count}"
puts "  Projects: #{Project.count}"
puts "  Tasks:    #{Task.count}"
puts "  '#{api.name}' progress: #{api.progress}%"
