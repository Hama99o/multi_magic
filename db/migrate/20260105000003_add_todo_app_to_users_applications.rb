class AddTodoAppToUsersApplications < ActiveRecord::Migration[7.0]
  def up
    User.find_each do |user|
      apps = user.applications || []
      unless apps.include?('TodoApp')
        apps << 'TodoApp'
        user.update_column(:applications, apps)
      end
    end
  end

  def down
    User.find_each do |user|
      apps = user.applications || []
      if apps.include?('TodoApp')
        apps.delete('TodoApp')
        user.update_column(:applications, apps)
      end
    end
  end
end
