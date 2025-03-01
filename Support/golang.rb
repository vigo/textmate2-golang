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
    
    will_save_errors = []
    
    unless ENV['TM_GOLANG_DISABLE_GOIMPORTS']
      out, err = Linter.goimports :input => @document
      # logger.info "out: #{out.inspect} -- err: #{err.inspect}"

      if err.empty?
        @document = out
      else
        logger.error "goimports err, #{err.inspect}"
        will_save_errors.concat(err.split("\n").map { |line| "(goimports):" + line })
        # logger.error "will_save_errors, #{will_save_errors.inspect}"
        # will_save_errors << "(goimports):#{err}"
      end
    end
    
    unless will_save_errors.empty?
      create_storage(will_save_errors)
    end
    
    # unless ENV['TM_GOLANG_DISABLE_GOFUMPT']
    #   out, err = Linter.gofumpt :input => @document
    #   logger.info "out: #{out.inspect} -- err: #{err.inspect}"
    #
    #   if err.empty?
    #     @document = out
    #   else
    #     logger.error "goimports err, #{err.inspect}" unless err.empty?
    #     create_storage([err])
    #   end
    # end
    
    print @document
  end
  
  def run_document_did_save
    exit_discard unless enabled?
    check_bunle_requirements

    @document = STDIN.read
    
    exit_discard if document_empty?
    exit_discard if document_has_first_line_comment?

    storage_errs = get_storage
    if storage_errs
      logger.error "storage_err: #{storage_errs.inspect}"

      errors = organize_errors(storage_errs)
      set_markers("error", errors)
      exit_boxify_tool_tip(boxify_errors(errors))
    end
    
    success_message = []
    success_message << "🎉 congrats! \"#{TM_FILENAME}\" has zero errors 👍\n"
    success_message << "✅ [goimports]" unless ENV['TM_GOLANG_DISABLE_GOIMPORTS']
    
    exit_boxify_tool_tip(success_message.join("\n"))
  end
  
end