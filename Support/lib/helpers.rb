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
        messages << "#{data[:message]}"
      end

      set_marker(mark, line_number, messages.join("\n"))
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
  
  def boxify_errors(errors, line_count)
    messages = []
    go_to_errors = []

    messages << "⚠️ Found #{errors.size} #{pluralize(errors.size, "error")}! ⚠️\n"
    messages << "🔍 Use Option ( ⌥ ) + G to jump error line!"
    
    errors.each do |error_line, errs|
      errs.sort_by{|err| err[:line_number]}.each do |err|
        messages << "  - #{err[:line_number]} -> #{err[:message]}"
        
        fmt_ln = pad_number(line_count, err[:line_number])
        fmt_cn = pad_number(line_count, err[:column_number])
        go_to_errors << "#{fmt_ln}:#{fmt_cn} | #{err[:message]}"
      end
    end
    
    create_storage(go_to_errors, true) if go_to_errors
    messages.join("\n")
  end
  
  def organize_errors(errors)
    errs = {}

    errors.each do |error|
      if error =~ /^\((.*)\):(.*):(\d+):(\d+):\s?(.*)$/
        error_type, file, line_number, column_number, message = $1, $2, $3.to_i, $4.to_i, $5
        errs[line_number] = [] unless errs.has_key?(line_number)

        err = {
          :line_number => line_number,
          :column_number => column_number,
          :type => error_type,
          :message => "[#{error_type}]: #{message}",
        }
        errs[line_number] << err
      end
    end
    
    errs
  end
end