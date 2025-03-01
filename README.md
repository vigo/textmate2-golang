![Version](https://img.shields.io/badge/version-0.0.0-orange.svg)

# TextMate2 Golang Bundle

If you’re still using [TextMate 2][textmate2] in 2025 and developing with
[Go][golang], this TextMate bundle will be a game-changer for you! 🚀

---

## Installation

You need `go` installation:

```bash
brew install go
```

Check if your `go` installation is ok?

```bash
$ go version
go version go1.24.0 darwin/arm64
```

You need to set `TM_GO` and `TM_GOPATH` TextMate variables:

```bash
defaults write com.macromates.TextMate environmentVariables \
    -array-add "{enabled = 1; value = \"$(command -v go)\"; name = \"TM_GO\"; }"

defaults write com.macromates.TextMate environmentVariables \
    -array-add "{enabled = 1; value = \"$(go env GOPATH)\"; name = \"TM_GOPATH\"; }"
```

You need to set `PATH` manually from `TextMate > Settings > Variables`:

    PATH    "${TM_GOPATH}/bin:/opt/homebrew/bin:${PATH}"

You can also set manually from your global or project based `.tm_properties`
file, I prefer this way:

    TM_GO=/path/to/go/libexec/bin/go  # result of command -v go
    TM_GOPATH=/path/to/go             # result of go env GOPATH
    PATH="${TM_GOPATH}/bin:/opt/homebrew/bin:${PATH}"

> It’s not possible to execute shell command in `.tm_properties` therefore
you need to set values by your hand!

If you are an old/aged developer like me :) you can set bigger fonts via:

```bash
defaults write com.macromates.TextMate NSToolTipsFontSize 24
```

You need to install go related tools, all are optional:

- `goimports`: `go install golang.org/x/tools/cmd/goimports@latest`

---

## TODO

- [X] `goimports`
- [ ] `gofumpt`
- [ ] `golines`
- [ ] `shadow`
- [ ] `staticcheck`
- [ ] `golangci-lint`
- [ ] `gopls` LSP
- [ ] Lots of snippets
- [ ] Go tools updater script

---

## TextMate Variables

| Variable | Default Value | Description |
|:---------|:--------------|:------------|
| `ENABLE_LOGGING` |  | Set this for bundle development purposes |
| `TM_GO` |  | Path to your `go` binary (e.g: `/opt/homebrew/opt/go/libexec/bin/go` )  |
| `TM_GOPATH` |  | Your `GOPATH` from `go env GOPATH` (e.g: `/Users/vigo/.local/go` find the value via `go env GOPATH` )  |
| `TM_GOLANG_DISABLE` |  | Disable bundle |
| `TM_GOLANG_DISABLE_GOIMPORTS` |  | Disable `goimports` |

To set your TextMate variables, go to `TextMate > Settings > Variables` and
set the values. Some variables only need to have any value assigned in order
to be activated. Such as:

    TM_GOLANG_DISABLE           1
    TM_GOLANG_DISABLE_GOIMPORTS 1

---

## Toggle Features

@wip

---

## Hot Keys and Snippets

@wip

---

## Bug Report

@wip

---

## Change Log

@wip

You can read the whole story [here][changelog].

---

## Contributor(s)

* [Uğur "vigo" Özyılmazel](https://github.com/vigo) - Creator, maintainer

---

## Contribute

All PR’s are welcome!

1. `fork` (https://github.com/vigo/textmate2-golang/fork)
1. Create your `branch` (`git checkout -b my-features`)
1. `commit` yours (`git commit -am 'implement new features'`)
1. `push` your `branch` (`git push origin my-features`)
1. Than create a new **Pull Request**!

---

## License

This project is licensed under MIT

---

[textmate2]: https://github.com/textmate/textmate
[golang]: https://go.dev/
[changelog]: https://github.com/vigo/textmate2-golang/blob/main/CHANGELOG.md