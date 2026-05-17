import * as admin from 'firebase-admin'

// Initialize Firebase Admin SDK once
// Set FIREBASE_SERVICE_ACCOUNT_KEY env var to the JSON string of your service account key
// Download from: Firebase Console → Project Settings → Service Accounts → Generate new private key
if (!admin.apps.length) {
  const serviceAccountKey = process.env.FIREBASE_SERVICE_ACCOUNT_KEY

  if (serviceAccountKey) {
    try {
      const serviceAccount = JSON.parse(serviceAccountKey)
      admin.initializeApp({
        credential: admin.credential.cert(serviceAccount),
      })
    } catch {
      console.error('[Firebase] Failed to parse FIREBASE_SERVICE_ACCOUNT_KEY — FCM disabled')
      admin.initializeApp()
    }
  } else {
    // Initialize without credentials — FCM will be disabled but other Admin features unavailable
    console.warn('[Firebase] FIREBASE_SERVICE_ACCOUNT_KEY not set — FCM push notifications disabled')
    admin.initializeApp()
  }
}

export const firebaseAdmin = admin
export const messaging = admin.messaging()

export async function sendPushNotification(
  token: string,
  title: string,
  body: string,
  data?: Record<string, string>,
): Promise<boolean> {
  if (!admin.apps.length) {
    console.warn('[FCM] Skipped — admin app not initialized')
    return false
  }
  try {
    await messaging.send({
      token,
      notification: { title, body },
      data,
      android: { priority: 'high' },
      apns: { payload: { aps: { sound: 'default', badge: 1 } } },
    })
    return true
  } catch (err) {
    console.error('[FCM] Send failed:', err)
    return false
  }
}

export async function sendPushToMultiple(
  tokens: string[],
  title: string,
  body: string,
  data?: Record<string, string>,
): Promise<{ success: number; failure: number }> {
  if (!tokens.length || !admin.apps.length) {
    return { success: 0, failure: tokens.length }
  }
  const response = await messaging.sendEachForMulticast({
    tokens,
    notification: { title, body },
    data,
    android: { priority: 'high' },
    apns: { payload: { aps: { sound: 'default', badge: 1 } } },
  })
  return { success: response.successCount, failure: response.failureCount }
}
