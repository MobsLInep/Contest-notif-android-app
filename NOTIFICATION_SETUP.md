# Push Notification Setup Guide

This guide explains how to set up and test the push notification system in your Flutter app.

## Prerequisites

1. **Firebase Project**: You need a Firebase project with Cloud Messaging enabled
2. **Backend Server**: A server to handle FCM token registration and send notifications
3. **Firebase Configuration**: Proper Firebase configuration files

## Setup Steps

### 1. Firebase Configuration

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project or select existing one
3. Enable Cloud Messaging
4. Download configuration files:
   - `google-services.json` for Android (place in `android/app/`)
   - `GoogleService-Info.plist` for iOS (place in `ios/Runner/`)

### 2. Update Backend URL

In `lib/services/notification_service.dart`, update the backend URL:

```dart
static const String _backendUrl = 'https://your-actual-backend-url.com/api';
```

### 3. Backend Implementation

Implement the API endpoints described in `BACKEND_API.md`:

- `POST /api/register-token` - Register FCM token with user preferences
- `POST /api/send-test-notification` - Send test notifications

### 4. Build and Test

1. Build the app: `flutter build apk` (or `flutter build ios`)
2. Install on device
3. Grant notification permissions when prompted
4. Set a Codeforces handle in the profile
5. Go to Profile → Settings → Notification Settings
6. Configure your notification preferences
7. Test notifications using the test button

## Testing Flow

### 1. Initial Setup
1. Install app on device
2. Grant notification permissions
3. Set Codeforces handle in profile
4. Check console logs for FCM token

### 2. Test Notifications
1. Go to Profile → Settings → Notification Settings
2. Use "Send Test Notification" button
3. Check device for notification
4. Verify notification appears

### 3. Test Different Settings
1. Toggle different notification settings
2. Verify settings are saved
3. Test with backend to ensure preferences are synced

## Troubleshooting

### Common Issues

1. **No FCM Token Generated**
   - Check Firebase configuration files
   - Verify internet connection
   - Check app permissions

2. **Test Notifications Not Working**
   - Verify backend URL is correct
   - Check backend logs for errors
   - Ensure FCM token is valid

3. **Notifications Not Appearing**
   - Check device notification settings
   - Verify app has notification permissions
   - Check if Do Not Disturb is enabled

### Debug Steps

1. **Check Console Logs**
   ```bash
   flutter logs
   ```

2. **Verify FCM Token**
   - Look for "FCM Token:" in console output
   - Token should be a long string

3. **Test Backend Connection**
   - Use curl or Postman to test API endpoints
   - Verify response codes

### Firebase Console Testing

1. Go to Firebase Console → Cloud Messaging
2. Click "Send your first message"
3. Use the FCM token from console logs
4. Send a test message
5. Verify notification appears on device

## Production Considerations

1. **Security**
   - Implement proper authentication
   - Use HTTPS for all API calls
   - Validate FCM tokens

2. **Performance**
   - Implement retry logic for failed notifications
   - Monitor delivery rates
   - Handle token refresh properly

3. **User Experience**
   - Provide clear notification settings
   - Allow users to opt out
   - Respect user preferences

## Monitoring

Monitor these key metrics:
- FCM token registration success rate
- Notification delivery success rate
- User engagement with notifications
- Error rates and types

## Support

If you encounter issues:
1. Check the troubleshooting section above
2. Review Firebase Console logs
3. Check backend server logs
4. Verify all configuration files are correct 