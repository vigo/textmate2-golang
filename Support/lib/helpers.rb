require ENV['TM_SUPPORT_PATH'] + '/lib/exit_codes'

require ENV['TM_BUNDLE_SUPPORT'] + '/lib/constants'
require ENV['TM_BUNDLE_SUPPORT'] + '/lib/storage'

class String
  def tokenize
    self.
      split(/\s(?=(?:[^'"]|'[^']*'|"[^"]*")*$)/).
      select {|s| not s.empty? }.
      map {|s| s.gsub(/(^ +)|( +$)|(^["']+)|(["]+$)/, '')}
  end
end

module Helpers
  include Constants

  extend Storage
  extend Logging  

  module_function

  def pluralize(n, singular, plural=nil)
    return plural.nil? ? singular + "s" : plural if n > 1
    return singular
  end

  def goto(line)
    system(ENV["TM_MATE"], "--uuid", TM_DOCUMENT_UUID, "--line", line)
  end

  def reset_markers
    system(
      ENV["TM_MATE"],
      "--uuid", TM_DOCUMENT_UUID,
      "--clear-mark=note",
      "--clear-mark=warning",
      "--clear-mark=error"
    )
  end

  def set_marker(mark, line, msg)
    unless line.nil?
      tm_args = [
        '--uuid', TM_DOCUMENT_UUID,
        '--line', "#{line}",
        '--set-mark', "#{mark}:#{msg}",
      ]
      system(ENV['TM_MATE'], *tm_args)
    end
  end

  def set_markers(mark, errors_list)
    errors_list.each do |line_number, errors|
      messages = []
      
      errors.each do |data|
        if data.has_key?(:file)
          if TM_FILEPATH =~ /#{data[:file]}$/
            messages << "#{data[:message]}"
          end
        end
      end

      set_marker(mark, line_number, messages.join("\n")) if messages.size > 0
    end
  end

  def exit_discard
    TextMate.exit_discard
  end
  
  def chunkify(s, max_len, left_padding)
    out = []
    s.split("\n").each do |line|
      if line.size > max_len
        words_matrix = []
        words_matrix_index = 0
        words_len = 0
        line.split(" ").each do |word|
          unless words_matrix[words_matrix_index].nil?
            words_len = words_matrix[words_matrix_index].join(" ").size
          end
          if words_len + word.size < max_len
            words_matrix[words_matrix_index] = [] if words_matrix[words_matrix_index].nil?
            words_matrix[words_matrix_index] << word
          else
            words_matrix_index = words_matrix_index + 1
            words_matrix[words_matrix_index] = [] if words_matrix[words_matrix_index].nil?
            words_matrix[words_matrix_index] << word
          end
        end
        
        rows = []
        padding_word = " " * left_padding
        words_matrix.each do |row|
          rows << "#{padding_word}#{row.join(" ")}" 
        end
        out << rows.join("\n#{padding_word}↪")
      else
        out << line
      end
    end
    out.join("\n")
  end

  def boxify(txt)
    s = chunkify(txt, TOOLTIP_LINE_LENGTH.to_i, TOOLTIP_LEFT_PADDING.to_i)
    s = s.split("\n")
    ll = s.map{|l| l.size}.max || 1
    lsp = TOOLTIP_BORDER_CHAR * ll
    s.unshift(lsp)
    s << lsp
    s = s.map{|l| "  #{l}  "}
    s.join("\n")
  end

  def exit_boxify_tool_tip(msg)
    TextMate.exit_show_tool_tip(boxify(msg))
  end

  def pad_number(lines_count, line_number)
    padding = lines_count.to_s.length
    padding = 2 if lines_count < 10
    return sprintf("%0#{padding}d", line_number)
  end
  
  def boxify_errors(errors, lines_count)
    messages = []
    go_to_errors = []

    errors_size = errors.values.map { |arr| arr.size }.inject(0) { |sum, count| sum + count }

    messages << "⚠️ #{errors_size} #{pluralize(errors_size, "error")} were found in total! ⚠️"
    messages << TOOLTIP_BORDER_CHAR * TOOLTIP_LINE_LENGTH.to_i
    messages << ''

    sorted_errors = errors.sort_by { |key, _| key }
    any_external_file_error = false

    popup_messages = []
    sorted_errors.each do |error_item|
      line_number = error_item[0]
      line_errors = error_item[1]
      line_errors.sort_by{|err| err[:line_number]}.each do |err|
        fmt_ln = pad_number(lines_count, err[:line_number])
        fmt_cn = pad_number(lines_count, err[:column_number])
        
        other_filename = ''
        if err.has_key?(:file)
          if TM_FILEPATH =~ /#{err[:file]}$/
            go_to_errors << "#{fmt_ln}:#{fmt_cn} | #{err[:message]}"
          else
            any_external_file_error = true
            other_filename = "👽 in: [#{err[:file]}]: "
          end
        end
        
        popup_messages << "  - #{other_filename}#{fmt_ln} -> #{err[:message]}"
      end
    end
    if go_to_errors.size > 0
      create_storage(go_to_errors, true)
      messages << "🔍 Use Option ( ⌥ ) + G to jump error line!"
    end

    messages << "👽 Error found in different file!" if any_external_file_error
    messages << ""

    messages.concat(popup_messages).join("\n")
  end
  
  def organize_errors(errors)
    errs = {}

    errors.each do |error|
      logger.info "original error: #{error.inspect}"
      case error
      when /^\((.*)\):(.*):(\d+):(\d+):\s?(.*)$/
        error_type, file, line_number, column_number, message = $1, $2, $3.to_i, $4.to_i, $5
        logger.fatal "error_type: #{error_type} - file: #{file}"
        errs[line_number] = [] unless errs.has_key?(line_number)
        err = {
          :file => file.sub(/^(vet|shadow): ?\.\//, ''),
          :line_number => line_number,
          :column_number => column_number,
          :type => error_type,
          :message => "[#{error_type}]: #{message}",
        }
        errs[line_number] << err
      when /^\((.*)\):(.*):(\d+):(\d+):\s?(.*)$/
        error_type, file, line_number, column_number, message = $1, $2, $3.to_i, $4.to_i, $5
        errs[line_number] = [] unless errs.has_key?(line_number)
        err = {
          :file => file.sub(/^\.\//, ''),
          :line_number => line_number,
          :column_number => column_number,
          :type => error_type,
          :message => "[#{error_type}]: #{message}",
        }
        errs[line_number] << err
      else
        errs[0] = [] unless errs.has_key?(0)
        err = {
          :line_number => 0,
          :column_number => 0,
          :type => "???",
          :message => error.chomp,
        }
        errs[0] << err
      end
    end
    errs
  end
  
  def match_need_go_module(relative_path)
    args = [ENV['TM_GO'], 'list', '-f', '{{.Path}}', '-m']
    modules, _ = TextMate::Process.run(args, :chdir => TM_PROJECT_DIRECTORY)

    matched_module = nil
    modules.split.each do |module_name|
      if relative_path.include?(module_name)
        matched_module = module_name
        break
      end
    end
    matched_module
  end
  
end