# Security Policy

## Supported Versions

| Version | Supported          |
|---------|--------------------|
| latest  | :white_check_mark: |

## Reporting a Vulnerability

If you discover a security vulnerability in DualClip, please report it responsibly:

1. **Do NOT open a public issue.**
2. Email the maintainer directly at: woojinim64@gmail.com
3. Include a detailed description of the vulnerability and steps to reproduce it.

You can expect an initial response within **72 hours**. Critical issues will be prioritized and patched as soon as possible.

## Security Design

DualClip is designed with security and privacy as core principles:

- **No Persistence**: Clipboard data exists only in memory and is never written to disk.
- **No Network Access**: The app makes zero external network requests — no telemetry, no analytics.
- **Minimal Permissions**: Only Accessibility permission is required (for keystroke simulation).
- **Open Source**: Full source code transparency for security-sensitive clipboard operations.

## Scope

This policy applies to the DualClip macOS application and its source code hosted in this repository.
