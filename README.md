# MechX — Flutter Source

MechX is a Flutter customer/mechanic marketplace app using Riverpod for shared state and Supabase for authentication and application data. The UI follows the MechX design system (cards, service tiles, booking flow, mechanic flow, and dark mode).

## Run it

1. Copy this folder's contents into a fresh `flutter create mechx` project
   (or use it as-is if you already have a Flutter project — just merge `lib/`
   and `pubspec.yaml`).
2. `flutter pub get`
3. `flutter run`

Maps currently use `MapPlaceholder` so the app can run without a Maps API key. Replace it with `GoogleMap(...)` when you are ready to configure Google Maps.

## Structure

```
lib/
  cores/
    config/
    models/
    providers/
    repositories/
    theme/
    app_colors.dart      → raw color tokens (same hex values as the HTML kit)
    app_theme.dart        → ThemeData (light/dark) + AppColorsExt for extra
                             semantic colors (surface2, textMuted, accent...)
                             Access via: context.colors.textMuted
  widgets/
    app_buttons.dart      → AccentButton, PrimaryButton, OutlineActionButton,
                             SmallAccentButton
    app_atoms.dart        → AppCard, ServiceTile, OfferRow, StatMini,
                             AppFieldBox, MapPlaceholder, MapPin
    gauge_arc.dart         → the signature speedometer-arc widget
    step_progress.dart    → StepProgress (booking-flow stepper), FlowAppBar
  screens/
    splash_screen.dart
    role_select_screen.dart
    login_screen.dart
    customer/
      customer_home_screen.dart
      select_vehicle_screen.dart      (step 1)
      select_service_screen.dart      (step 2)
      issue_details_screen.dart       (step 3)
      set_location_screen.dart        (step 4)
      offers_screen.dart              (step 5 — the bidding screen)
      tracking_screen.dart            (step 6)
      payment_rating_screen.dart      (step 7 — combined pay + rate, end of main flow)
      chat_screen.dart                (customer ↔ mechanic messaging)
      booking_history_screen.dart     (Upcoming / Completed tabs)
      payment_method_screen.dart      (standalone payment picker)
      rate_mechanic_screen.dart       (standalone rating screen)
    mechanic/
      mechanic_home_screen.dart
      new_request_screen.dart
      send_offer_screen.dart
      job_accepted_screen.dart
      on_the_way_screen.dart
      job_completed_screen.dart
      earnings_screen.dart            (full earnings history page)
  main.dart                → MaterialApp + Riverpod ProviderScope
```

## Navigation map

**Customer:** Splash → Role Select → Login → Home →
[Select Vehicle → Select Service → Issue Details → Set Location → Offers →
Tracking → Payment & Rating] → back to Home.
From Home's bottom nav: Bookings → Booking History (tap an upcoming item →
Payment Method → Rate Mechanic). Chat tab / Tracking screen's Chat button →
Chat screen.

**Mechanic:** Login → Mechanic Home → New Request → Send Offer →
Job Accepted → On The Way → Job Completed → back to Mechanic Home.
Tapping the earnings card on Mechanic Home → full Earnings screen.

## Adding a new screen

Follow the pattern of any existing screen: wrap in `Scaffold`, use
`FlowAppBar` for booking-flow screens, pull colors from
`context.colors.xxx` (never hardcode hex — keeps light/dark consistent),
and reuse the widgets in `widgets/` before writing new ones.

## Screens not yet converted

All screens from the HTML kit are now ported **except** the Admin Dashboard —
that one is a web panel (React or Flutter Web target), not part of this
mobile app codebase. Ask when you're ready to start that separately.

## Environment

Create a `.env` file in the project root using `.env.example` as a template. Never commit `.env` or service credentials.

## Supabase

Run `supabase_schema.sql` in the Supabase SQL Editor before testing the data-backed screens. The schema contains RLS policies for profiles, vehicles, bookings, offers, chat, reviews, notifications, and avatar storage.

## Live Supabase update
The latest build removes fixed demo records from booking requests, offers, mechanic requests, tracking details, chat, earnings and payment totals. Run the complete `supabase_schema.sql` again in Supabase SQL Editor before testing this flow.
