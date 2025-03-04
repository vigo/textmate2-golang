require ENV['TM_SUPPORT_PATH'] + '/lib/ui'

require ENV['TM_BUNDLE_SUPPORT'] + '/lib/constants'
require ENV['TM_BUNDLE_SUPPORT'] + '/lib/logger'

module Complete
  include Logging
  include Constants
  
  module_function
  def basic
    logger.info "ruby version: #{RUBY_VERSION}"
    # puts TM_CURRENT_WORD
    # choices = ['hello', 'world']
    # choices = [
    #   {'match' => 'moo', 'display' => 'Hairy Monkey'},
    #   {'match' => 'foo', 'display' => 'Purple Turtles'},
    # ]
    choices = [
      {'display': 'Println(a ...any) (n int, err error)', 'match' => 'Println', 'insert' => '(${1:a ...any})' },
      {'display': '123456789x123456789x123456789x123456789x', 'match' => 'Println', 'insert' => '(${1:a ...any})' },
      # {'image' => 'Drag',    'display' => 'text', 'insert' => '(${1:one}, ${2:one}, ${3:three}${4:, ${5:five}, ${6:six}})',     'tool_tip_format' => "text", 'tool_tip' => "<div> not html <div>"},
      # {'image' => 'Command', 'display' => 'text', 'insert' => '(${1:one}, ${2:one}, "${3:three}"${4:, "${5:five}", ${6:six}})',                              'tool_tip' => "<div> not html <div>"},
    ]
    TextMate::UI.complete(choices)
  end
end