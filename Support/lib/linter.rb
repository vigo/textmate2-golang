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
    args = options[:args] || []
    cmd = [TM_GOIMPORTS_BINARY, args]

    if input.nil?
      cmd << TM_FILEPATH
    else
      cmd << {:input => input}
    end
    
    return TextMate::Process.run(*cmd)
  end

  def gofumpt(options={})
    input = options[:input]
    args = options[:args] || []
    cmd = [TM_GOFUMPT_BINARY, args]

    if input.nil?
      cmd << TM_FILEPATH
    else
      cmd << {:input => input}
    end

    return TextMate::Process.run(*cmd)
  end

  def golines(options={})
    input = options[:input]
    args = options[:args] || []
    args.concat(['-m', TM_GOLINES_MAX_LEN, '-t', TM_GOLINES_TAB_LEN])
    args.concat(['--shorten-comments']) if TM_GOLINES_SHORTEN_COMMENTS
    
    cmd = [TM_GOLINES_BINARY, args]

    if input.nil?
      cmd << TM_FILEPATH
    else
      cmd << {:input => input}
    end

    return TextMate::Process.run(*cmd)
  end
  
end