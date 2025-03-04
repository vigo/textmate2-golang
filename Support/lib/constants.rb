module Constants
  TM_GOLANG_DISABLE = !!ENV['TM_GOLANG_DISABLE']
  TM_GOLANG_DISABLE_GOIMPORTS = !!ENV['TM_GOLANG_DISABLE_GOIMPORTS']
  TM_GOLANG_DISABLE_GOFUMPT = !!ENV['TM_GOLANG_DISABLE_GOFUMPT']
  TM_GOLANG_DISABLE_GOLINES = !!ENV['TM_GOLANG_DISABLE_GOLINES']
  TM_GOLANG_DISABLE_GOVET = !!ENV['TM_GOLANG_DISABLE_GOVET']
  TM_GOLANG_DISABLE_GOSHADOW = !!ENV['TM_GOLANG_DISABLE_GOSHADOW']
  TM_GOLANG_DISABLE_FIELDALIGNMENT = !!ENV['TM_GOLANG_DISABLE_FIELDALIGNMENT']
  TM_GOLANG_DISABLE_GOLANGCI_LINTER = !!ENV['TM_GOLANG_DISABLE_GOLANGCI_LINTER']
  
  TM_GOLINES_MAX_LEN = ENV['TM_GOLINES_MAX_LEN'] || '100'
  TM_GOLINES_TAB_LEN = ENV['TM_GOLINES_TAB_LEN'] || '4'
  TM_GOLINES_SHORTEN_COMMENTS = !!ENV['TM_GOLINES_SHORTEN_COMMENTS']

  TM_GOLANG_HIDE_TOOL_INFO_ON_SUCCESS = !!ENV['TM_GOLANG_HIDE_TOOL_INFO_ON_SUCCESS']
  
  TM_PROJECT_DIRECTORY = ENV['TM_PROJECT_DIRECTORY']
  TM_FILENAME = ENV['TM_FILENAME']
  TM_FILEPATH = ENV['TM_FILEPATH']
  TM_DOCUMENT_UUID = ENV['TM_DOCUMENT_UUID']
  TM_CURRENT_WORD = ENV['TM_CURRENT_WORD']

  TOOLTIP_LINE_LENGTH = ENV['TM_GOLANG_TOOLTIP_LINE_LENGTH'] || '100'
  TOOLTIP_LEFT_PADDING = ENV['TM_GOLANG_TOOLTIP_LEFT_PADDING'] || '2'
  TOOLTIP_BORDER_CHAR = ENV['TM_GOLANG_TOOLTIP_BORDER_CHAR'] || '-'

  GOLANGCI_LINTER_OPTIONS = ENV['GOLANGCI_LINTER_OPTIONS']

  TM_GOIMPORTS_BINARY = ENV['TM_GOIMPORTS_BINARY'] || `command -v goimports`.chomp

  TM_GOFUMPT_BINARY = ENV['TM_GOFUMPT_BINARY'] || `command -v gofumpt`.chomp
  TM_GOFUMPT_BINARY_VERSION = `#{TM_GOFUMPT_BINARY} -version`.chomp

  TM_GOLINES_BINARY = ENV['TM_GOLINES_BINARY'] || `command -v golines`.chomp

  TM_GOSHADOW_BINARY = ENV['TM_GOSHADOW_BINARY'] || `command -v shadow`.chomp

  TM_GOFIELDALIGNMENT_BINARY = ENV['TM_GOFIELDALIGNMENT_BINARY'] || `command -v fieldalignment`.chomp
  
  TM_GOLANGCI_LINTER_BINARY = ENV['TM_GOLANGCI_LINTER_BINARY'] || `command -v golangci-lint`.chomp
  TM_GOLANGCI_LINTER_BINARY_VERSION = `#{TM_GOLANGCI_LINTER_BINARY} version | /usr/bin/grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | xargs | cut -d' ' -f1`.chomp

  TM_GO_BINARY_VERSION = `#{ENV['TM_GO']} version | grep -oE 'go[0-9]+\.[0-9]+\.[0-9]+'`.chomp
  
  ENABLE_LOGGING = ENV['ENABLE_LOGGING']
end
