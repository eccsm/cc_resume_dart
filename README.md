# cc_resume_app

A Flutter application that presents a digital resume for Ekincan Casim, showcasing professional experience, skills, education, and contact information in a clean, interactive UI with chatbot functionality.

## Overview

**cc_resume_app** is a cross-platform Flutter app that displays your resume in a modern, mobile-friendly format. It uses resume constants for the content, and includes support for dynamic theming, asset management, animations, and Firebase integration for web hosting and analytics.

## Features

- **Clean, Interactive UI:**  
  Present your resume details using a drag-and-drop, responsive layout with animated elements.
  
- **Chatbot Integration:**  
  Interactive chat widget for visitors to engage with your digital resume.

- **Modular Architecture:**  
  Separates UI widgets from static content, making it easy to update or extend.

- **Firebase Integration:**  
  Web hosting, analytics, and performance monitoring to track visitor engagement.

- **PDF Generation:**  
  Ability to generate a downloadable PDF version of the resume.

- **Asset Management:**  
  Custom fonts, images, and icons for a personalized experience.

## Getting Started

### Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install) (latest stable release recommended)
- [Dart SDK](https://dart.dev/get-dart) (comes with Flutter)
- [Firebase Account](https://firebase.google.com/) (for web hosting and analytics)
- A code editor (e.g., VS Code, Android Studio)

### Installation

1. **Clone the Repository:**

   ```bash
   git clone https://github.com/eccsm/cc_resume_app.git
   cd cc_resume_app
   ```
2. **Install Dependencies:**

    Run the following command in the project directory:

    ```bash
    flutter pub get
    ```
3. **Set Up Firebase (Optional):**

    If you want to use Firebase for web hosting and analytics:

    - Create a Firebase project at [firebase.google.com](https://firebase.google.com/)
    - Add your app to the Firebase project
    - Download the configuration files (google-services.json for Android, GoogleService-Info.plist for iOS)
    - Place the configuration files in the appropriate directories
    - Ensure Firebase configuration is set up in your app (lib/firebase_options.dart)

4. **Set Up Environment Variables (Optional):**

    Create a .env file in the root directory for any sensitive API keys or configuration.

5. **Run the App:**

    Use the following command to run the app on your connected device or emulator:

    ```bash
    flutter run
    ```
   
## Project Structure
```
cc_resume_app/
├── android/            # Android-specific code
├── ios/                # iOS-specific code
├── web/                # Web-specific code
├── assets/
│   ├── images/         # Images and icons
│   └── fonts/          # Custom fonts
├── lib/
│   ├── firebase_options.dart   # Firebase configuration
│   ├── resume_constants.dart   # Resume content
│   ├── main.dart              # App entry point
│   ├── pdf/                   # PDF generation logic
│   └── widgets/               # Custom widgets (e.g., ChatWidget, TypingIndicator)
├── test/               # Unit and widget tests
├── .env                # Environment variables (excluded from Git)
├── pubspec.yaml        # Dependency and asset configuration
└── README.md           # This file
```

## Usage

- **Viewing the Resume:**
    Launch the app to see the digital resume. Navigate through sections to explore professional details.

- **Interacting with the Chatbot:**
    Use the draggable chat widget to ask questions about the resume.

- **Updating Content:**
    Update the static content in lib/resume_constants.dart or create a separate configuration file.

- **Deploying to Web:**
    Deploy to Firebase Hosting with:
    ```bash
    flutter build web --release --web-renderer canvaskit
    firebase deploy
    ```

## Features in Detail

### Responsive Design
The app uses responsive_framework and flutter_screenutil to ensure optimal display across different device sizes.

### Animations
Implemented with animated_text_kit for engaging text transitions and custom animations for UI elements.

### Firebase Integration
Analytics, performance monitoring, and hosting capabilities through Firebase services.

## Contributing
Feel free to fork this repository and submit pull requests. For major changes, please open an issue first to discuss what you would like to change.

## License
This project is licensed under the MIT License.

## Contact
For any questions or further information, please reach out via LinkedIn or GitHub.