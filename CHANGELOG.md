# Change Log

**2026-02-19**

- Add `TM_GO_PROJECT_ROOT` env-var for monorepo / sub-directory support.
  When `go.mod` is not in the project root, set this variable to the relative
  path of the Go project directory (e.g. `backend`).

**2025-03-03**

- Add `TM_GOLANG_HIDE_TOOL_INFO_ON_SUCCESS` env-var check to toggle tool
  information on success message.

**2025-03-02**

- Add some snippets
- Add `.golangci.yml` creation command

**2025-03-01**

- Add `goimports`
- Add `gofumpt`
- Add `golines`
- Add `go vet`
- Add `go vet` with `shadow`
- Add `fieldalignment` autofix
- Add go tools installer with: option + I
- Add go to error line with: option + G
- Add `golangci-lint` integration

**2025-02-28**

- Initial development started
