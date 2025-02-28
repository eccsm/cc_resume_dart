# Security Policy

## Reporting a Vulnerability

If you discover a security vulnerability within this project, please send an email to me. All security vulnerabilities will be promptly addressed.

## Credential Exposure in Git History

> ⚠️ **CRITICAL SECURITY ALERT**
>
> Firebase API keys and configuration were accidentally committed to this repository in previous commits in the following files:
>
> - `lib/firebase_options.dart`
> - `android/app/google-services.json`
>
> These files have now been added to `.gitignore`, but **the sensitive data remains in the Git history**.

### Required Actions

If you are the owner of this repository or have forked it:

1. **Rotate All Firebase API Keys Immediately**:
   - Visit the [Firebase Console](https://console.firebase.google.com/)
   - Go to Project Settings > Service accounts
   - Click "Manage API Keys" to rotate them
   - Update all local configuration files with the new keys

2. **Clean Git History**:
   - Use [BFG Repo-Cleaner](https://rtyley.github.io/bfg-repo-cleaner/) or `git filter-branch` to remove the sensitive files from your Git history
   - Example BFG command:
     ```
     bfg --delete-files firebase_options.dart --delete-files google-services.json
     ```
   - Follow up with:
     ```
     git reflog expire --expire=now --all && git gc --prune=now --aggressive
     ```
   - Force-push to overwrite the GitHub repository:
     ```
     git push --force
     ```

3. **Replace with Example Files**:
   - Use the provided example files (`*.example`) as templates
   - Create your own configuration files locally without committing them

## Best Practices for Credential Management

- Never commit sensitive API keys, tokens, or credentials to version control
- Use environment variables or secure secret management solutions
- Add sensitive files to `.gitignore` before initial commit
- Consider using pre-commit hooks to prevent accidental commits of sensitive files
- Use placeholders and example files for documentation

## Additional Resources

- [GitHub's guide to removing sensitive data from a repository](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/removing-sensitive-data-from-a-repository)
- [Firebase security best practices](https://firebase.google.com/docs/web/learn-more#secure-your-api-keys)
- [Git pre-commit hooks](https://pre-commit.com/)