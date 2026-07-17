# Roadmap

Planned work for SaveInstanceFetch. Items are proposals, not commitments — scope
may change. The current release is **v1.0.0** (see `version.txt`).

## v1.5.0 — Update system

Builds on the loader foundation added in v1.0.0 (embedded version, remote update
check, and on-disk source cache + fallback in `prepass.luau`). No new dependencies;
everything stays inside the existing executor APIs and repo-raw fetch model.

### Prioritized

1. **Version pinning / release channels** — let users lock to a specific tag or
   channel instead of always tracking `main`.
   - New `PrepassOptions.Ref` (branch/tag) and/or `PrepassOptions.Channel`
     (`"stable"` -> `main`, `"dev"` -> a preview branch).
   - Rationale: balances "always latest" against "always stable" when `main`
     temporarily breaks.

2. **Source integrity verification** — verify a downloaded source matches a
   published hash before running it.
   - Publish per-release FNV-1a hash (helper already exists in `prepass.luau`) in
     `version.txt` or a small manifest file.
   - Closes the "HTTP 200 but truncated/modified body" gap more tightly than the
     current compile-check.

3. **Changelog on update** — when a newer version is detected, fetch the top few
   lines of a repo `CHANGELOG.md` and print "what's new" alongside the version.
   - Makes the update notice useful, not just a version number.

### Secondary

4. **Cache metadata + auto-invalidate** — sidecar JSON (version + hash +
   timestamp) next to the cached main script so the loader knows which version is
   cached, can log "using cached v1.4.0", and auto-drops the cache when the remote
   version increases.

5. **Optional auto-update behavior** — `AutoUpdate` toggle governing whether a
   detected newer version is adopted for the current run or merely reported.

## Notes / follow-ups from v1.0.0

- Keep `SAVEINSTANCE_VERSION` (in `saveinstance.luau`) and `version.txt` in sync on
  every release. A pre-commit hook could enforce this, but per project guardrails
  no new tooling is added without an explicit request.
- Verification for all loader/update work is static-only: the code depends on
  Roblox executor APIs unavailable in a normal Luau runtime.
