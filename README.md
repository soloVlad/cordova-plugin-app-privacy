# AppPrivacyPlugin

A Cordova plugin to enhance application privacy by hiding sensitive content when the app is minimized and controlling screenshot behavior.

## 🛠 Installation

```bash
cordova plugin add cordova-plugin-app-privacy
```

## Example

```typescript
const enablePrivacyMode = () => {
  cordova.plugins.AppPrivacyPlugin.enablePrivacyMode();
}

const disablePrivacyMode = () => {
  cordova.plugins.AppPrivacyPlugin.disablePrivacyMode();
}
```

## Methods
| Methods  | Type |
| ------------- | ------------- |
| enablePrivacyMode  | (): void  |
| disablePrivacyMode  | (): void  |

## 📲 Supported Platforms
- Android
- iOS

## ✨ Features
- **Android**:
  - When privacy mode is enabled:
    - App content is hidden when minimized.
    - Screenshots are blocked and show a blank screen.
- **iOS**:
  - When privacy mode is enabled:
    - App content is hidden when the app is minimized.
    - **Screenshots cannot be blocked** (iOS limitation).

