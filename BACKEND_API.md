# Backend API Documentation for Push Notifications

This document outlines the API endpoints that your backend needs to implement to support the push notification system.

## Base URL
```
https://your-backend-url.com/api
```

## Endpoints

### 1. Register FCM Token
**POST** `/register-token`

Registers a user's FCM token with their notification preferences.

**Request Body:**
```json
{
  "userId": "string", // Codeforces handle
  "fcmToken": "string", // FCM device token
  "notificationSettings": {
    "notify30min": true,
    "notify10min": true,
    "notifyCustom": true,
    "notifyLive": true
  }
}
```

**Response:**
- **200 OK**: Token registered successfully
- **400 Bad Request**: Invalid request data
- **500 Internal Server Error**: Server error

### 2. Send Test Notification
**POST** `/send-test-notification`

Sends a test notification to verify the setup.

**Request Body:**
```json
{
  "fcmToken": "string",
  "title": "Test Notification",
  "body": "This is a test notification from your app!",
  "data": {
    "type": "test",
    "timestamp": "1234567890"
  }
}
```

**Response:**
- **200 OK**: Test notification sent successfully
- **400 Bad Request**: Invalid request data
- **500 Internal Server Error**: Server error

## Backend Implementation Guide

### Database Schema
You'll need to store user notification preferences:

```sql
CREATE TABLE user_notifications (
  id SERIAL PRIMARY KEY,
  user_id VARCHAR(255) NOT NULL,
  fcm_token TEXT NOT NULL,
  notify_30min BOOLEAN DEFAULT true,
  notify_10min BOOLEAN DEFAULT true,
  notify_custom BOOLEAN DEFAULT true,
  notify_live BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### FCM Integration
Your backend should use the Firebase Admin SDK to send notifications:

```javascript
// Node.js example
const admin = require('firebase-admin');

// Initialize Firebase Admin
admin.initializeApp({
  credential: admin.credential.applicationDefault(),
});

// Send notification
async function sendNotification(fcmToken, title, body, data = {}) {
  const message = {
    notification: {
      title: title,
      body: body,
    },
    data: data,
    token: fcmToken,
  };

  try {
    const response = await admin.messaging().send(message);
    console.log('Successfully sent message:', response);
    return response;
  } catch (error) {
    console.log('Error sending message:', error);
    throw error;
  }
}
```

### Contest Notification Logic
Your backend should implement logic to send notifications for contests:

1. **30 minutes before contest**: Check contests starting in 30 minutes
2. **10 minutes before contest**: Check contests starting in 10 minutes
3. **Custom contests**: Send notifications for custom contests
4. **Live contests**: Send notifications when contests go live

Example cron job (Node.js):
```javascript
const cron = require('node-cron');

// Check for contests starting in 30 minutes
cron.schedule('*/5 * * * *', async () => {
  const contests = await getUpcomingContests();
  const now = new Date();
  
  for (const contest of contests) {
    const contestStart = new Date(contest.startTimeSeconds * 1000);
    const timeDiff = contestStart - now;
    const minutesDiff = Math.floor(timeDiff / (1000 * 60));
    
    if (minutesDiff === 30 || minutesDiff === 10) {
      const users = await getUsersWithNotificationPreference(minutesDiff);
      
      for (const user of users) {
        await sendNotification(
          user.fcm_token,
          `Contest Reminder: ${contest.name}`,
          `Contest starts in ${minutesDiff} minutes!`,
          {
            type: 'contest_reminder',
            contestId: contest.id.toString(),
            contestName: contest.name,
          }
        );
      }
    }
  }
});
```

## Testing

1. Use the test notification button in the app
2. Check Firebase Console for delivery status
3. Monitor your backend logs for any errors
4. Test with different notification settings

## Security Considerations

1. **Authentication**: Implement proper authentication for your API endpoints
2. **Rate Limiting**: Add rate limiting to prevent abuse
3. **Token Validation**: Validate FCM tokens before storing
4. **HTTPS**: Always use HTTPS in production
5. **Input Validation**: Validate all input data

## Error Handling

Handle common FCM errors:
- **Invalid Token**: Remove invalid tokens from database
- **Not Registered**: Token is no longer valid
- **Quota Exceeded**: Implement retry logic with exponential backoff
- **Server Unavailable**: Implement retry logic

## Monitoring

Monitor these metrics:
- Token registration success rate
- Notification delivery success rate
- User engagement with notifications
- Error rates and types 