package it.cnr.cdt;

import android.util.Log;

import androidx.annotation.NonNull;

import com.google.firebase.messaging.FirebaseMessagingService;
import com.google.firebase.messaging.RemoteMessage;

public class MessagingService extends FirebaseMessagingService {

    private static final String TAG = "MessagingService";

    @Override
    public void onNewToken(@NonNull String fcm_token) {
        super.onNewToken(fcm_token);
        Log.d(TAG, "New token: " + fcm_token);
        String token = getSharedPreferences("cdt", MODE_PRIVATE).getString("id", null);
    }

    @Override
    public void onMessageReceived(@NonNull RemoteMessage remoteMessage) {
        super.onMessageReceived(remoteMessage);
    }
}
