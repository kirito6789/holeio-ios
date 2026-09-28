# Project Singularity iOS

A native `WKWebView` wrapper for the MIT-licensed [Project Singularity](https://github.com/frankstop/HoleIO) browser game.

The upstream game is pinned to commit `4707e86791f8824198e98c518732740501fbdbc0`, built as static assets, and bundled into the app. It runs fully offline through a custom `game://` URL scheme.

## Build

GitHub Actions builds an unsigned IPA on a free macOS runner. Use `iLoader` with the user's free Apple ID to sign and install it.

## App identity

- Display name: 黑洞吞噬
- Bundle identifier: `cn.codex.holeio`
- Minimum iOS: 15.0
- Supports portrait, landscape left, and landscape right
