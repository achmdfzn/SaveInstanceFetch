# Changelog

## v1.5.0

Update system and loader resilience.

- Version awareness: `saveinstance.luau` now carries a `SAVEINSTANCE_VERSION` constant, published in `version.txt`. The loader reports whether you are up to date, behind, or ahead.
- Update notices with changelog: when a newer version is published, the loader prints the top of this changelog so you can see what changed.
- Offline fallback: the last good `saveinstance.luau` is cached on disk (with a version/hash/timestamp sidecar) and used automatically when a download fails or returns a bad body.
- Source integrity check: a downloaded source is verified against the hash published in `version.txt` (when present) before it is trusted or cached, so a truncated or 200-served error page can't run or poison the cache.
- Release channels and version pinning: `Channel` / `Ref` select a repo branch or tag, and `PinVersion` refuses to run anything other than the version you pinned.

All new behavior is controlled by `PrepassOptions` and defaults sensibly. No new dependencies.

## v1.0.0

Initial published baseline of SaveInstanceFetch: terrain, unions, decompile prepass, and asset recovery, loaded straight from GitHub raw.
