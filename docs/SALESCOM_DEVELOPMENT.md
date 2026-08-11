# Salescom development and upstream policy

Salescom is maintained as an MIT-only product based on Chatwoot's community
edition. The Chatwoot Enterprise overlay is intentionally not part of this
repository or the running application.

## Product code boundaries

- Put Salescom-specific backend code under a `Salescom` namespace in new files,
  such as `app/services/salescom`, `app/models/salescom`, and
  `app/controllers/salescom`.
- Put Salescom-specific frontend code in `app/javascript/dashboard/salescom` or
  focused feature directories with `Salescom`-specific names.
- Add database changes as new migrations. Never edit a migration that has
  already shipped.
- Prefer small integration points in shared Chatwoot files. Do not fork a whole
  controller or model when a service, concern, event listener, or policy can
  provide the extension point.
- Do not copy code from Chatwoot's `enterprise/` directory into Salescom code.
- Keep the root MIT license and all required third-party license notices.

## Enterprise-free invariant

`ChatwootApp.enterprise?` must remain false. CI and release reviews should fail
if an upstream merge adds an `enterprise/` or `spec/enterprise/` directory, an
Enterprise API import, or a direct `Enterprise::` constant reference.

Use this audit after every upstream merge:

```bash
test ! -d enterprise
test ! -d spec/enterprise
! rg -n "Enterprise::|api/enterprise" app config lib
```

Feature flag entries already stored in account bit fields must not be reordered
or removed. Inert upstream feature keys may remain for database compatibility;
new Salescom feature keys should be appended or stored in Salescom-owned
entitlement tables.

## Syncing Chatwoot improvements

Configure the public Chatwoot repository as a read-only upstream remote:

```bash
git remote add upstream https://github.com/chatwoot/chatwoot.git
git remote set-url --push upstream DISABLED
git fetch upstream
```

Create a dedicated sync branch for each upstream release:

```bash
git switch -c chore/sync-chatwoot-vX.Y.Z
git merge --no-commit --no-ff vX.Y.Z
```

During conflict resolution:

1. Keep Enterprise files deleted.
2. Preserve the Salescom brand, metadata, palette, and MIT-only runtime.
3. Prefer upstream security fixes, dependency updates, bug fixes, migrations,
   and performance improvements.
4. Review new routes, background jobs, feature flags, external integrations,
   and migrations individually instead of accepting them wholesale.
5. Re-run the enterprise-free audit, backend tests, frontend tests, linting, and
   a production build before merging the sync branch.

Do not merge directly from upstream into the production branch. Keeping each
sync in its own reviewed commit makes future audits and reversions practical.

## Sales-focused roadmap boundary

Salescom-owned services should cover ad-lead intake, AI qualification, human
handoff, purchase outcome capture, and conversion feedback integrations. Keep
provider-specific APIs behind Salescom services so Meta and other ad platforms
can evolve without coupling those protocols to shared Chatwoot models.
