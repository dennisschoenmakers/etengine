namespace :db do
  desc "Move production db to staging db, overwriting everything"
  task :prod2staging_all do    
    warning("You know what you're doing, right? You will overwrite the entire staging db!")
    
    puts "Loading production environment"
      production
    puts "Dumping database #{db_name} to /tmp"
      file = dump_db_to_tmp
    puts "Loading staging environment"
      staging
      puts "target database: #{db_name}"
    puts "I should now be emptying staging"
      db.empty
    puts "And filling staging with production data"
      load_sql_into_db(file)
  end
  
  desc "Copy users, and scenarios from production to staging with the exception of protected and preset scenarios"
  task :prod2staging_safe_tables do
    warning "users and (partially) scenarios tables on staging will be overwritten with production data"
    puts "Loading production environment"
      production
    puts "Dumping tables #{db_name} to /tmp"
      tables = %w{
        users
      }
      file = dump_db_to_tmp(tables)
    puts "Loading staging environment"
      staging
      puts "target database: #{db_name}"
    puts "And filling staging with production data"
      load_sql_into_db(file)
      
    puts "Now let's make a dump of the scenarios we don't need"

    puts "Loading production environment"
      production
    puts "Dumping tables #{db_name} to /tmp"
      file = dump_db_to_tmp(['scenarios'], "--where='in_start_page != 1 AND protected != 1' --skip-add-drop-table")
    puts "Loading staging environment"
      staging
      puts "target database: #{db_name}"
    puts "remove useless scenarios"
      run_mysql_query "DELETE FROM scenarios WHERE in_start_page != 1 AND protected != 1"
    puts "And filling staging with production data"
      load_sql_into_db(file)

  end  

  desc "Move staging db to production db, overwriting everything"
  task :staging2prod_all do    
    warning("You know what you're doing, right? You will overwrite the entire production db!")
    
    puts "Loading staging environment"
      staging
    puts "Dumping database #{db_name} to /tmp"
      file = dump_db_to_tmp
    puts "Loading production environment"
      production
      puts "target database: #{db_name}"
    puts "I should now be emptying production"
      db.empty
    puts "And filling production with staging data"
      load_sql_into_db(file)
  end
  
  desc "Empty db - be sure you know what you're doing"
  task :empty do
    warning("You know what you're doing, right? This will drop the current db")
    
    puts "Dropping the remote db and recreating a new one!"
    puts "I'll first make a backup on /tmp though"
    dump_db_to_tmp
    run "mysqladmin drop #{db_name}"
    run "mysqladmin create #{db_name} -u #{db_user} --password=#{db_pass}"
  end
  
  desc "If you've unintenionally ran db:empty"
  task :oops do
    puts "Shame on you!"
    file = "/tmp/#{db_name}.sql"
    run "mysql -u #{db_user} --password=#{db_pass} --host=#{db_host} #{db_name} < #{file}"
  end
end

desc "Move db server to local db"
task :db2local do
  file = dump_db_to_tmp
  puts "Gzipping sql file"
    run "gzip -f #{file}"
  puts "Downloading gzip file"
    get file + ".gz", "#{db_name}.sql.gz"
  puts "Gunzip gzip file"
    system "gunzip -f #{db_name}.sql.gz"
  puts "Importing sql file to db"
    system "mysqladmin -f -u root drop #{local_db_name}"
    system "mysqladmin -u root create #{local_db_name}"
    system "mysql -u root #{local_db_name} < #{db_name}.sql"
end

# Helper methods

# dumps the entire db to the tmp folder and returns the full filename
# the optional tables parameter should be an array of string
def dump_db_to_tmp(tables = [], options = nil)
  file = "/tmp/#{db_name}.sql"
  puts "Exporting db to sql file, filename: #{file}"
  run "mysqldump -u #{db_user} --password=#{db_pass} --host=#{db_host} #{db_name} #{tables.join(' ')} #{options} > #{file}"
  file
end

# watchout! this works on remote boxes, not on the developer box
def load_sql_into_db(file)
  puts "Importing sql file to db"
  run "mysql -u #{db_user} --password=#{db_pass} --host=#{db_host} #{db_name} < #{file}"
end

def warning(msg)
  puts "Warning! These tasks have destructive effects."
  unless Capistrano::CLI.ui.agree(msg)
    puts "Wise man"; exit
  end
end

def run_mysql_query(q)
  run "mysql -u #{db_user} --password=#{db_pass} --host=#{db_host} #{db_name} -e '#{q}'"
end
