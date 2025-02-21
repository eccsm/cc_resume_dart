# cc_resume_dart

A Flutter application that presents a digital resume for Ekincan Casim, showcasing professional experience, skills, education, and contact information in a clean, interactive UI.

## Overview

**cc_resume_dart** is a cross-platform Flutter app that displays your resume in a modern, mobile-friendly format. It uses a set of refactored resume constants for the content, and includes support for dynamic theming, asset management, and local configuration for sensitive data.

## Features

- **Clean, Interactive UI:**  
  Present your resume details using a drag-and-drop, responsive layout.
  
- **Modular Architecture:**  
  Separates UI widgets from static content, making it easy to update or extend.

- **Local Configuration:**  
  Sensitive or private data (like resume content) can be loaded from a local file (e.g. `config.local.dart`) that is excluded from version control.

- **Asset Management:**  
  Easily manage images and icons (e.g., your personal icons for "Sug" and "Pep").

## Getting Started

### Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install) (latest stable release recommended)
- [Dart SDK](https://dart.dev/get-dart) (comes with Flutter)
- A code editor (e.g., VS Code, Android Studio)

### Installation

1. **Clone the Repository:**

   ```bash
   git clone https://github.com/eccsm/cc_resume_dart.git
   cd cc_resume_dart
   ```
2. **Install Dependencies:**

    Run the following command in the project directory:

    ```bash
    flutter pub get
     ```
3. **Set Up Local Configuration (Optional):**

    If your project uses a local configuration file for sensitive resume data:

    - Create a file called lib/config.local.dart (this file should not be committed).

    - Add your configuration in the following format:

    ```dart
    // lib/config.local.dart
    const Map<String, dynamic> resumeConstants = {
      'basicInformation': {
        'name': 'Ekincan Casim',
        'location': 'Istanbul, Turkey',
        // ...other private info...
      },
      // ...additional sections...
    };
    ```
    - Ensure lib/config.local.dart is listed in your .gitignore.


4. **Run the App:**

    Use the following command to run the app on your connected device or emulator:

    ```bash
    flutter run
     ```
   
## Project Structure
```bash
cc_resume_dart/
├── android/
├── ios/
├── lib/
│   ├── assets/             # (if applicable, not tracked if sensitive)
│   ├── config.local.dart   # Local configuration (excluded from Git)
│   ├── refactored_resume_constants.dart  # Public resume constants
│   ├── main.dart           # App entry point
│   └── widgets/            # Custom widgets (e.g., MessageBubble, TypingIndicatorBubble)
├── test/                   # Unit and widget tests
├── .gitignore              # Excludes sensitive files/folders
├── pubspec.yaml            # Dependency and asset configuration
└── README.md               # This file
```
## Usage
- **Viewing the Resume:**

    Launch the app to see the digital resume. Swipe or scroll to explore your professional details.

- **Updating Content:**
  
    Update the static content in lib/refactored_resume_constants.dart or, for sensitive data, in your local configuration file (lib/config.local.dart).

- **Asset Management:**
    
    If using sensitive assets (e.g., images), store them locally and update the .gitignore to prevent them from being committed.

## Contributing
Feel free to fork this repository and submit pull requests. For major changes, please open an issue first to discuss what you would like to change.

## License
This project is licensed under the MIT License.

## Contact
For any questions or further information, please reach out via LinkedIn or GitHub.

