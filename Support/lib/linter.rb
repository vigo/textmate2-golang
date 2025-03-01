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
  
  def get_lookup()
    go_mod = "#{TM_PROJECT_DIRECTORY}/go.mod"
    go_work = "#{TM_PROJECT_DIRECTORY}/go.work"
    relative_path = TM_FILEPATH.gsub(/^#{Regexp.escape(TM_PROJECT_DIRECTORY)}/, '')

    lookup = File.exists?(go_mod) ? './...' : TM_FILENAME
    if File.exists?(go_work)
      matched_module = match_need_go_module(relative_path)
      lookup = "./#{matched_module}/..." unless matched_module.nil?
    end

    lookup
  end
  
  def govet(options={})
    args = options[:args] || []
    args.concat(['vet', get_lookup])
    return TextMate::Process.run(ENV['TM_GO'], args, :chdir => TM_PROJECT_DIRECTORY)
  end

  def govet_shadow(options={})
    args = options[:args] || []

    args.concat(['vet', '-vettool', TM_GOSHADOW_BINARY, get_lookup])
    return TextMate::Process.run(ENV['TM_GO'], args, :chdir => TM_PROJECT_DIRECTORY)
  end

end