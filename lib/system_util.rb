class SystemUtil
  def self.run_with_err_output(command)
    puts command
    %x{ #{command} 2>&1 }
  end
end
