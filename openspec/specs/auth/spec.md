## Purpose

Provides account identity for Lexivo: sign-up, sign-in, session persistence, and account settings via Supabase Auth behind a swappable AuthProvider adapter.

## Requirements

### Requirement: Sign up and sign in
The system SHALL allow users to create an account and sign in using Supabase Auth as the launch AuthProvider, without custom password/session crypto in application code.

#### Scenario: Successful sign-in
- **WHEN** a user submits valid credentials
- **THEN** the system establishes an authenticated session and persists it across app restarts

#### Scenario: Invalid credentials
- **WHEN** a user submits invalid credentials
- **THEN** the system rejects the attempt with a clear error and does not create a session

### Requirement: Token verification via AuthProvider
The backend SHALL verify bearer tokens only through the AuthProvider protocol (`verify_token`), with Supabase as the default adapter binding and Clerk remaining an alternate adapter implementation.

#### Scenario: Protected API call
- **WHEN** a client calls a protected endpoint with a valid token
- **THEN** the AuthProvider returns a UserIdentity and the request proceeds

#### Scenario: Missing or invalid token
- **WHEN** a protected endpoint is called without a valid token
- **THEN** the system returns an unauthorized response

### Requirement: Account settings
The system SHALL allow an authenticated user to view and update basic account settings exposed by the auth/account feature without reaching into other features’ internals.

#### Scenario: Update profile fields
- **WHEN** an authenticated user updates allowed account fields
- **THEN** the changes persist and are reflected on subsequent loads

### Requirement: Frontend auth module boundary
The Flutter auth feature SHALL follow feature-first clean architecture (data/domain/presentation), expose only its barrel file publicly, and compose screens exclusively from design-system components.

#### Scenario: Cross-feature import ban
- **WHEN** another feature needs auth state
- **THEN** it MUST consume auth via domain providers or route guards, never via auth data-layer imports
