namespace :ridgepole do
  desc 'Dry-run migration'
  task 'dry-run': :environment do
    sh 'bin/ridgepole', '--apply', '--dry-run', '--config', 'config/database.yml', '--env', Rails.env, '--file', 'db/Schemafile'
  end

  desc 'Apply migration'
  task apply: :environment do
    sh 'bin/ridgepole', '--apply', '--config', 'config/database.yml', '--env', Rails.env, '--file', 'db/Schemafile'
  end
end
