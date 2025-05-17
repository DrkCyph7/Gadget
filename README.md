# GadgetZilla - Flutter Product Listing App

GadgetZilla is a Flutter mobile application that allows users to browse, search, filter, save, and share tech products. It integrates with Firebase Firestore for real-time product data and supports push notifications.

## Features

- Browse products by categories like Smart Tech, Mobile Accessories, Productivity Gadgets, and more.
- Search products with a debounced search bar.
- Filter products by category using selectable chips.
- Save favorite products with a heart icon toggle.
- View saved items separately.
- Share product links and open product URLs externally.
- Notification screen accessible from the home app bar.
- Smooth page navigation with a custom bottom navigation bar.
- Add new product listings via a floating action button.

## Tech Stack

- Flutter (Dart)
- Firebase Firestore (Realtime database)
- share_plus (sharing functionality)
- url_launcher (opening URLs)
- Clipboard API (copy URLs)

## Getting Started

### Prerequisites

- Flutter SDK installed ([Flutter installation guide](https://flutter.dev/docs/get-started/install))
- Firebase project configured with Firestore enabled
- Android/iOS device or emulator setup

### Installation

1. Clone this repository:

   ```bash
   git clone https://github.com/yourusername/gadgetzilla.git
   cd gadgetzilla

	2.	Install dependencies:

flutter pub get


	3.	Configure Firebase:
	•	Add your google-services.json (Android) and GoogleService-Info.plist (iOS) files.
	•	Follow Firebase Flutter integration guide.
	4.	Run the app:

flutter run



Project Structure
	•	lib/screens/ - Contains screen widgets like HomeScreen, MyListingsScreen, AccountScreen, NotificationScreen.
	•	lib/widgets/ - Custom reusable widgets (e.g., Navbar, ProductTile).
	•	lib/main.dart - App entry point.

Notes
	•	The app uses a real-time listener to Firestore to keep product data up to date.
	•	Saved products are marked with a heart icon; tapping toggles the saved state.
	•	Notifications currently navigate to a dedicated screen.
	•	The app has basic exit confirmation on the home screen back button.


License
MIT License. See LICENSE file for details.
