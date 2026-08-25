# CONTEXT.md

Domain glossary for the ISU-CAMP user-facing mobile application.

## Terms

### Auth Session
The fact that a person is signed in, plus the display name the app greets them with.
Created by a successful login or registration. The user app does not persist it yet;
until a real backend exists it lives only in memory for the duration of the flow.

### Verification Code
A six-digit code a person enters to prove control of their email during password
reset. In the current frontend-only phase it is never actually sent anywhere;
the reset flow accepts any six-digit code.

### Password Reset
The flow: request (forgot password) → verify code → set new password.
Distinct from registration and from changing a password while signed in
(which the app does not have yet).
