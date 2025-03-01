require 'tempfile'
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
  
  def autofix_fieldalignment(options={})
    input = options[:input]
    temp_file = Tempfile.new(['fieldalignment', '.go'])
    temp_file.write(input)
    temp_file.close
    
    fixed_code = input

    _, err = TextMate::Process.run(TM_GOFIELDALIGNMENT_BINARY, '-fix', temp_file.path)
    unless err.empty?
      fixed_code = File.read(temp_file.path)
    end
    temp_file.unlink
    
    return fixed_code, err
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
  
  def has_golangci_lint_config_file?
    has_config_file = false
    ['yml', 'yaml', 'toml', 'json'].each do |ext|
      if File.exists?("#{TM_PROJECT_DIRECTORY}/.golangci.#{ext}")
        has_config_file = true
        break
      end
    end
    has_config_file
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

  def golangci_lint(options={})
    args = options[:args] || []
    args.concat(['run'])
    args.concat(['--color', 'never'])
    args.concat(['--disable-all'] + GOLANGCI_LINTER_OPTIONS.split(' ')) if !has_golangci_lint_config_file? && GOLANGCI_LINTER_OPTIONS
    logger.info "golangci_lint args: #{args.inspect}"
    return TextMate::Process.run(TM_GOLANGCI_LINTER_BINARY, args, :chdir => TM_PROJECT_DIRECTORY)
  end

end