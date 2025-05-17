# GadgetZilla

GadgetZilla is a modern Flutter-based mobile application that showcases trending gadgets and tech accessories. Leveraging Firebase Firestore for real-time product data and user-specific saved items, it provides an intuitive browsing, searching, filtering, and saving experience.

---

## Table of Contents

- [Features](#features)  
- [Screenshots](#screenshots)  
- [Architecture](#architecture)  
- [Setup and Installation](#setup-and-installation)  
- [Usage](#usage)  
- [Folder Structure](#folder-structure)  
- [Technologies Used](#technologies-used)  
- [Contributing](#contributing)  
- [License](#license)  
- [Contact](#contact)

---

## Features

- **Discover Products:** Browse a wide range of gadgets, categorized under Smart Tech, Mobile Accessories, Productivity Gadgets, and more.
- **Real-time Data:** Firestore integration with real-time updates for product listings.
- **Search & Filter:** Powerful search with debounce and category filters.
- **Save Favorites:** Mark products as favorites with a heart icon, persisting saved state.
- **Product Actions:** View product details, open URLs, copy links, and share products directly from the app.
- **Bottom Navigation:** Smooth bottom navigation for switching between Discover, Search, Saved Items, and Account screens.
- **Notifications:** Push notification integration for new products (setup required).
- **Responsive UI:** Adaptive layout for phones and tablets.
- **Custom Transitions:** Slide transitions for notifications screen.
- **Exit Confirmation:** Double back-press or confirmation dialog on exit.

---

## Screenshots

_(Add screenshots or GIFs showcasing your app here)_

---

## Architecture

The app uses a **StatefulWidget** architecture for screens with `setState` management. It uses:

- **Firestore Streams** for live data updates.
- **StreamSubscription** to listen and update product lists.
- **Debounce Timer** to reduce search input lag.
- **Modal Bottom Sheets** for product options.
- **Custom Widgets** such as `ProductTile` for clean UI.
- **Navigator & PageRouteBuilder** for custom page transitions.

---

## Setup and Installation

### Prerequisites

- Flutter SDK >= 3.x  
- Dart >= 2.18.x  
- Firebase account and Firestore database setup  
- Android Studio / VS Code with Flutter plugin  
- Real device or emulator  

### Steps

1. **Clone this repository**

   ```bash
   git clone https://github.com/yourusername/gadgetzilla.git
   cd gadgetzilla

	2.	Install dependencies

flutter pub get


	3.	Firebase Setup
	•	Create a Firebase project at Firebase Console
	•	Add Android and/or iOS apps in Firebase
	•	Download and place google-services.json (Android) or GoogleService-Info.plist (iOS) in your project
	•	Enable Firestore database with a collection named items
	•	Structure your items documents with fields:
	•	name (String)
	•	description (String)
	•	category (String)
	•	imageUrl (String)
	•	url (String)
	4.	Run the app

flutter run



⸻

Usage
	•	Use the Discover tab to browse and filter products by category.
	•	Use the Search tab to quickly find products by name.
	•	Tap the heart icon on product tiles to save or unsave favorites.
	•	Access product options by tapping a product card — open URL, copy link, or share.
	•	View saved items in the Saved tab.
	•	Navigate to the Account screen for user profile actions.
	•	Use the notification bell in the Discover tab to view notifications (if configured).
	•	Press back on the home tab to confirm exiting the app.

⸻

Folder Structure

lib/
├── main.dart
├── screens/
│   ├── home_screen.dart
│   ├── my_listing_screen.dart
│   ├── account_screen.dart
│   ├── notification.dart
│   ├── saved_items_screen.dart
│   └── navbar.dart
├── widgets/
│   └── product_tile.dart
├── services/
│   └── firebase_service.dart
└── utils/
    └── constants.dart


⸻

Technologies Used
	•	Flutter — Cross-platform UI toolkit
	•	Dart — Programming language
	•	Firebase Firestore — Real-time cloud NoSQL database
	•	share_plus — For native sharing support
	•	url_launcher — For opening external URLs
	•	flutter_local_notifications (optional) — For handling local notifications
	•	Provider / Riverpod (optional) — For advanced state management (if extended)

⸻

Contributing

Contributions are welcome! Feel free to open issues or submit pull requests for bugs, features, or improvements.
	1.	Fork the repo
	2.	Create your feature branch (git checkout -b feature/new-feature)
	3.	Commit your changes (git commit -am 'Add new feature')
	4.	Push to the branch (git push origin feature/new-feature)
	5.	Open a Pull Request

⸻

License

This project is licensed under the MIT License — see the LICENSE file for details.

⸻

Contact

Your Name — your.email@example.com
Project Link: https://github.com/yourusername/gadgetzilla

⸻

Happy Gadget Hunting! 🚀

If you want, I can save this as a file `/mnt/data/README.md` for you to download. Would you like me to do that?
