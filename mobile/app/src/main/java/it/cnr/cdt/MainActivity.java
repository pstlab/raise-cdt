package it.cnr.cdt;

import android.app.Activity;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.EditText;

import com.google.firebase.messaging.FirebaseMessaging;

import java.util.concurrent.Executors;

import androidx.annotation.NonNull;

import okhttp3.MediaType;
import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.RequestBody;
import okhttp3.Response;

public class MainActivity extends Activity {

    private static final String TAG = "MainActivity";
    private EditText tokenEditText;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main); // Set the layout for this activity

        tokenEditText = findViewById(R.id.token);
    }

    public void onCreateUserButtonClick(@NonNull View view) {
        Executors.newSingleThreadExecutor().execute(() -> {
            OkHttpClient client = new OkHttpClient();
            final Request.Builder builder = new Request.Builder().url("http://10.0.2.2:8080/users")
                    .post(RequestBody.create("{\"google_id\": \"" + tokenEditText.getText().toString() + "\"}",
                            MediaType.parse("application/json")));
            try (Response response = client.newCall(builder.build()).execute()) {
                if (response.isSuccessful()) {
                    String id = response.body().string();
                    getSharedPreferences("cdt", MODE_PRIVATE).edit().putString("id", id).apply();
                    FirebaseMessaging.getInstance().getToken().addOnCompleteListener(task -> {
                        if (task.isSuccessful()) {
                            Log.d(TAG, "FCM token retrieved successfully");
                            String fcm_token = task.getResult();
                            Log.d(TAG, "FCM Token: " + fcm_token);
                            Executors.newSingleThreadExecutor().execute(() -> newToken(id, fcm_token));
                        } else
                            Log.e("Connection", "Failed to get FCM token", task.getException());
                    });
                } else {
                    Log.e(TAG, "Failed to create user: " + response.code());
                }
            } catch (Exception e) {
                Log.e(TAG, "Error during user creation", e);
            }
        });
    }

    public void newToken(@NonNull String id, @NonNull String token) {
        OkHttpClient client = new OkHttpClient();
        final Request.Builder builder = new Request.Builder().url("http://10.0.2.2:8080/fcm_tokens")
                .post(RequestBody.create("{\"id\": \"" + id + "\", \"token\": \"" + token + "\"}",
                        MediaType.parse("application/json")));
        try (Response response = client.newCall(builder.build()).execute()) {
            if (response.isSuccessful()) {
                String responseBody = response.body().string();
                Log.d(TAG, "Token registered successfully: " + responseBody);
            } else {
                Log.e(TAG, "Failed to register token: " + response.code());
            }
        } catch (Exception e) {
            Log.e(TAG, "Error during token registration", e);
        }
    }
}
