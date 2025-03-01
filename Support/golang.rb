require ENV['TM_SUPPORT_PATH'] + '/lib/ui'

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
    required_bins << 'goimports' unless TM_GOLANG_DISABLE_GOIMPORTS
    required_bins << 'gofumpt' unless TM_GOLANG_DISABLE_GOFUMPT
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
    destroy_storage(true)

    exit_discard unless enabled?
    check_bunle_requirements

    @document = STDIN.read

    exit_discard if document_empty?
    exit_discard if document_has_first_line_comment?
    
    logger.info "will save"
    
    will_save_errors = []
    
    unless TM_GOLANG_DISABLE_GOFUMPT
      out, _ = Linter.gofumpt :input => @document
      @document = out
    end

    unless TM_GOLANG_DISABLE_GOIMPORTS
      out, err = Linter.goimports :input => @document

      if err.empty?
        @document = out
      else
        logger.error "goimports err, #{err.inspect}"
        will_save_errors.concat(err.split("\n").map { |line| "(goimports):" + line })
      end
    end

    unless TM_GOLANG_DISABLE_GOLINES
      out, err = Linter.golines :input => @document
      logger.warn "golines, out: #{out} -- err: #{err}"
      
      if err.empty?
        @document = out
      else
        logger.error "golines err, #{err.inspect}"
        will_save_errors.concat(err.split("\n").map { |line| "(golines):" + line })
      end
    end

    unless will_save_errors.empty?
      create_storage(will_save_errors)
    end
    
    
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

      lines_count = @document.split("\n").size
      errors = organize_errors(storage_errs)
      set_markers("error", errors)
      exit_boxify_tool_tip(boxify_errors(errors, lines_count))
    end
    
    enabled_checkers = [
      !TM_GOLANG_DISABLE_GOIMPORTS,
      !TM_GOLANG_DISABLE_GOFUMPT,
      !TM_GOLANG_DISABLE_GOLINES,
    ]
    logger.info "enabled_checkers: #{enabled_checkers.inspect}"
    
    success_message = []
    if enabled_checkers.any?
      success_message << "🎉 congrats! \"#{TM_FILENAME}\" has zero errors 👍\n"
      success_message << "✅ [goimports]" unless TM_GOLANG_DISABLE_GOIMPORTS
      success_message << "✅ [gofumpt] - #{TM_GOFUMPT_BINARY_VERSION}" unless TM_GOLANG_DISABLE_GOFUMPT
      success_message << "✅ [golines]" unless TM_GOLANG_DISABLE_GOLINES
    else
      success_message << "☢️ Heads up! nothing is checked, you have disabled all ☢️"
    end

    exit_boxify_tool_tip(success_message.join("\n"))
  end
  
  def goto_error
    if File.exist?(Storage::GOTO_FILE)
      goto_errors = File.read(Storage::GOTO_FILE)
      if goto_errors
        goto_errors = goto_errors.split("\n").sort
        selected_index = TextMate::UI.menu(goto_errors)
        unless selected_index.nil?
          selected_error = goto_errors[selected_index]
          if selected_error
            line = selected_error.split(" ").first
            system(ENV["TM_MATE"], "--uuid", TM_DOCUMENT_UUID, "--line", line)
          end
        end
      end
    end
  end
end