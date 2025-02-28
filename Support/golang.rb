require ENV['TM_BUNDLE_SUPPORT'] + '/lib/constants'
require ENV['TM_BUNDLE_SUPPORT'] + '/lib/logger'
require ENV['TM_BUNDLE_SUPPORT'] + '/lib/linter'
require ENV['TM_BUNDLE_SUPPORT'] + '/lib/storage'
require ENV['TM_BUNDLE_SUPPORT'] + '/lib/helpers'

module Golang
  include Logging
  include Constants
  
  extend Helpers
  extend Storage
  
  @document = nil
  
  module_function
  
  def enabled?
    !TM_GOLANG_DISABLE
  end
  
  def check_bunle_requirements
    required_env_names = ['TM_GO', 'TM_GOPATH']
    required_env_names.each do |name|
      exit_boxify_tool_tip("you need to set \"#{name}\" environment variable") unless ENV[name]
    end
    
    required_bins = []
    required_bins << 'goimports' unless ENV['TM_GOLANG_DISABLE_GOIMPORTS']
    required_bins.each do |name|
      exit_boxify_tool_tip("you need to install \"#{name}\" binary") unless !`command -v #{name} > /dev/null 2>&1 && echo $?`.chomp.empty?
    end
  end
  
  def document_empty?
    @document.nil? || @document.empty? || @document.match(/\S/).nil?
  end

  def document_has_first_line_comment?
    @document.split("\n").first.include?("// TM_GOLANG_DISABLE")
  end
  
  def run_document_will_save(options={})
    reset_markers
    destroy_storage
    exit_discard unless enabled?
    check_bunle_requirements

    @document = STDIN.read

    exit_discard if document_empty?
    exit_discard if document_has_first_line_comment?
    
    logger.info "will save"
    
    unless ENV['TM_GOLANG_DISABLE_GOIMPORTS']
      out, err = Linter.goimports :input => @document
      logger.info "out: #{out.inspect} -- err: #{err.inspect}"

      if err.empty?
        @document = out
      else
        logger.error "goimports err, #{err.inspect}" unless err.empty?
        create_storage([err])
      end
    end
    
    
    print @document
  end
  
  def run_document_did_save
    exit_discard unless enabled?
    check_bunle_requirements

    @document = STDIN.read
    
    exit_discard if document_empty?
    exit_discard if document_has_first_line_comment?

    storage_err = get_storage
    if storage_err
      logger.error "storage_err: #{storage_err.inspect}"
      exit_boxify_tool_tip(storage_err)
    end

  end
end