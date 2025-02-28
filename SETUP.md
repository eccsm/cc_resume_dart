# Configuration Setup Guide

This document explains how to set up the necessary configuration files for running the application.

## Environment Variables

1. Create a `.env` file in the root directory of the project
2. Copy the contents from `.env.example` to your new `.env` file
3. Replace placeholder values with your actual configuration values

Example:
```
API_BASE_URL=http://your-actual-api-url.com
DEBUG=true
ENV=development
```

## Firebase Configuration

### Android Configuration

1. Create a Firebase project at [firebase.google.com](https://firebase.google.com/)
2. Add an Android app to your Firebase project
3. Download the `google-services.json` file
4. Place the file in the `/android/app/` directory
5. Use the example in `google-services.json.example` as a reference

### Firebase Options

1. After setting up your Firebase project, you need to configure the Firebase options
2. Create a `firebase_options.dart` file in the `/lib/` directory
3. Use the template in `firebase_options.dart.example` as a reference
4. Replace all placeholders with your actual Firebase configuration values

### Firebase Project Settings

1. Create a `.firebaserc` file in the root directory
2. Copy the contents from `.firebaserc.example` to your new file
3. Replace `YOUR_PROJECT_ID` with your actual Firebase project ID

## Security Notes

> ⚠️ **IMPORTANT SECURITY WARNING**
>
> Previous commits contained sensitive API keys and Firebase credentials in `lib/firebase_options.dart` and `android/app/google-services.json`. These files have been added to `.gitignore`, but the API keys may still be exposed in the Git history!
>
> **Actions Required:**
> 
> 1. Rotate your Firebase API keys in the Firebase console immediately
> 2. Update your local configuration files with the new keys
> 3. Consider using [BFG Repo-Cleaner](https://rtyley.github.io/bfg-repo-cleaner/) or `git filter-branch` to remove sensitive data from Git history
> 4. **NEVER** commit any files containing API keys or secrets going forward
>
> For additional guidance on removing sensitive data from your repository, see [GitHub's guide on removing sensitive data](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/removing-sensitive-data-from-a-repository)

- Always keep sensitive files in the `.gitignore` list
- Use example files without sensitive information for documentation purposes
- Consider using environment variables or secure secret management solutions

## Troubleshooting

If you encounter issues with the Firebase setup, try the following:

1. Verify that all configuration files are in the correct locations
2. Ensure you've replaced all placeholder values with actual values
3. Run `flutter clean` and then `flutter pub get` to reset dependencies
4. If Firebase initialization fails, check for errors in the console logs