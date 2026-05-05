# daimkasa

daimkasa is the cashier-side companion to daim. Cafe and restaurant
staff use it to look up customer accounts, scan QR codes, take orders
and confirm payments, while the customer-facing daim app handles
points, rewards and membership.

## Features

- Phone verification sign-in
- Employee home with order flow
- QR code scanning for customer accounts
- Order details and order information screens
- Account and user information management
- Turkish and English localization

## Built With

- Flutter (Dart SDK ^3.6)
- Firebase: Core, Auth, Firestore
- Provider for state management
- mobile_scanner, flutter_screenutil
- shared_preferences, intl

## Getting Started

You'll need the Flutter SDK installed. Then:

```
flutter pub get
flutter run
```

## Configuration

The app uses Firebase. You'll need your own Firebase project and the
matching config files (`google-services.json` for Android,
`GoogleService-Info.plist` for iOS) with Auth and Firestore enabled.

## License

See `LICENSE`.
