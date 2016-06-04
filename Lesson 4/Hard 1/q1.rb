# frozen_string_literal: false
# Alyssa has been assigned a task of modifying a class that was initially created to keep track of secret information. The new requirement calls for adding logging, when clients of the class attempt to access the secret data. Here is the class in its current form:

# She needs to modify it so that any access to data must result in a log entry being generated. That is, any call to the class which will result in data being returned must first call a logging class. The logging class has been supplied to Alyssa and looks like the following

# Hint: Assume that you can modify the initialize method in SecretFile to have an instance of SecurityLogger be passed in as an additional argument. It may be helpful to review the lecture on collaborator objects for this exercise.
class SecretFile
  attr_reader :data

  def initialize(secret_data, logger)
    @data = secret_data
    @logger = logger
  end

  def retrieve_secret_data
    @logger.create_log_entry
    data
  end
end

class SecurityLogger
  def create_log_entry
    # ... implementation omitted ...
    puts "Log Entry Created."
  end
end

the_secret_data = "TOP SECRET!!!"
logger = SecurityLogger.new
my_secret_file = SecretFile.new(the_secret_data, logger)

puts my_secret_file.retrieve_secret_data
