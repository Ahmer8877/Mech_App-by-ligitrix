# Live Supabase + Compile Fixes

## Important
- Apple authentication configuration was not changed.
- Android/Gradle configuration was not changed.

## Fixes in this revision
- Moved `UserRole` into `lib/cores/models/user_role.dart` so core models/providers no longer depend on a screen.
- Fixed malformed Dart generated in customer chat, issue details, offers, payment, location, and tracking screens.
- Fixed mechanic job-completed and mechanic-bookings screen syntax.
- Removed unused imports and an unused booking-draft local variable.
- Kept customer vehicles/services/bookings/offers/chat connected to Supabase/Riverpod.
- Added error handling around payment/cancel/chat operations.
- Updated payment dropdowns to use `initialValue` instead of deprecated `value`.
