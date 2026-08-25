# Auth runs against an in-memory FakeAuthRepository until a backend contract exists

The user app's auth flows (login, registration, password reset) currently succeed
without any backend. Rather than leaving fake success scattered inside screen
handlers, we defined an async `AuthRepository` interface and made an in-memory
`FakeAuthRepository` its first adapter; the FastAPI stub in `server/` will grow a
second adapter later without the screens changing. The interface is `Future`-based
now so swapping adapters never rewrites callers, and the fake is minimally
realistic (registered accounts are remembered in memory) so flows and error paths
are exercisable end-to-end through the interface alone.

## Considered options

- Sync interface now, convert when the backend lands — rejected: every caller
  would be rewritten at phase 2 anyway.
- Faithful fake (accept anything, remember nothing) — rejected: it leaves error
  paths unexercisable, which defeats the seam's purpose as a test surface.
- Session persistence / secure storage — deferred deliberately: there is no real
  token to store yet.

## Consequences

- Auth state lives only in memory for the duration of a flow; signing in does not
  survive an app restart until a real adapter with storage exists.
- The `server/` directory is intentionally untouched by frontend work; its
  endpoints must be shaped to satisfy this interface, not the other way round.

## Amendment (2026-08-25): email is now collected at registration

Originally `register(username, password)` carried no email while all three
Password Reset operations keyed on email — no registered account was reachable
through any reset flow a user would actually exercise. Registration now requires
an `email` parameter (the register screen has a matching field), and the fake
stores and matches that real address instead of synthesizing one. The reset flow
is also stateful: `verifyResetCode`/`resetPassword` succeed only after
`requestPasswordReset` for the same account. A real adapter must implement the
same contract from stored emails; nothing about `<username>@example.com`
synthesis should be copied anywhere.
