require ENV['TM_SUPPORT_PATH'] + '/lib/tm/process'

require ENV['TM_BUNDLE_SUPPORT'] + '/lib/constants'
require ENV['TM_BUNDLE_SUPPORT'] + '/lib/logger'
require ENV['TM_BUNDLE_SUPPORT'] + '/lib/storage'
require ENV['TM_BUNDLE_SUPPORT'] + '/lib/helpers'

module Linter
  include Constants
  
  extend Logging::ClassMethods
  extend Storage
  extend Helpers
  
  module_function
  
  def goimports(options={})
    input = options[:input]
    args = options[:args]
    cmd = `command -v goimports`.chomp

    if input.nil?
      out, err = TextMate::Process.run(cmd, args, TM_FILEPATH)
    else
      out, err = TextMate::Process.run(cmd, args, :input => input)
    end
    
    return out, err
  end
  
end