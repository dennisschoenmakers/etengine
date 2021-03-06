# This initializer will catch the use of deprecated gqueries. Since there can be thousands of events
# we should decide what to do with them. At the moment I'm just showing them on the log. We could
# save them to a separate log file or store them externally and use a gquery counter.
#

if Rails.root.join('log').directory?
  GqlLogger   = Logger.new(Rails.root.join('log/gql.log'), 5, 1_048_576)
  GqlWarnings = Logger.new(Rails.root.join('log/warnings.log'), 5, 1_048_576)

  # For quick debugging sessions
  DebugLogger = Logger.new(Rails.root.join('log/debug.log'), 5, 1_048_576)
else
  # This only happens during a cold deploy, when running a setup Rake task
  # before the shared directories are symlinked.
  GqlLogger   = Logger.new($stderr)
  GqlWarnings = Logger.new($stderr)
  DebugLogger = Logger.new($stderr)
end

GqlWarnings.formatter = GqlLogger.formatter =
  proc do |severity, datetime, progname, message|
    progname = " #{ progname }" unless progname.nil?
    "[#{ datetime }#{ progname }] #{ message }\n"
  end

ActiveSupport::Notifications.subscribe 'gql.gquery.deprecated' do |name, start, finish, id, payload|
  GqlLogger.info "gql.gquery.deprecated: #{payload}"
end

ActiveSupport::Notifications.subscribe 'gql.debug' do |name, start, finish, id, payload|
  GqlLogger.debug "gql.debug: #{payload}"
end

# Show all 'performance' related outputs
ActiveSupport::Notifications.subscribe /^warn/ do |name|
  GqlWarnings.warn name
end

# Show all 'performance' related outputs
ActiveSupport::Notifications.subscribe /\.performance/ do |name, start, finish, id, payload|
  GqlLogger.debug "#{(name+":").ljust(80)} #{(finish - start).round(3).to_s.ljust(5)} s"
end

ActiveSupport::Notifications.subscribe /etsource.loader/ do |name, start, finish, id, payload|
  GqlLogger.debug "#{(name+":").ljust(80)} #{(finish - start).round(3).to_s.ljust(5)} s"
end

ActiveSupport::Notifications.subscribe /qernel.merit_order/ do |name, start, finish, id, payload|
  GqlLogger.debug "#{(name+":").ljust(80)} #{(finish - start).round(3).to_s.ljust(5)} s"
end

ActiveSupport::Notifications.subscribe /gql\.query/ do |name, start, finish, id, payload|
  GqlLogger.debug "#{(name+":").ljust(80)} #{(finish - start).round(3).to_s.ljust(5)} s"
end

ActiveSupport::Notifications.subscribe /gql\.inputs/ do |name, start, finish, id, payload|
  GqlLogger.debug "#{name}: #{payload}"
end

def dbg(x)
  DebugLogger.debug x
end

