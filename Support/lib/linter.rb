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

    if input.nil?
      out, err = TextMate::Process.run(TM_GOIMPORTS_BINARY, args, TM_FILEPATH)
    else
      out, err = TextMate::Process.run(TM_GOIMPORTS_BINARY, args, :input => input)
    end
    
    return out, err
  end

  def gofumpt(options={})
    input = options[:input]
    args = options[:args]

    if input.nil?
      out, err = TextMate::Process.run(TM_GOFUMPT_BINARY, args, TM_FILEPATH)
    else
      out, err = TextMate::Process.run(TM_GOFUMPT_BINARY, args, :input => input)
    end
    
    return out, err
  end
  
end