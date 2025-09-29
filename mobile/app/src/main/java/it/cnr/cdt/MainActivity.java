package it.cnr.cdt;

import android.app.Activity;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;

import com.google.firebase.messaging.FirebaseMessaging;
import com.google.gson.Gson;
import com.google.gson.JsonObject;

import java.util.concurrent.Executors;

import androidx.annotation.NonNull;

import okhttp3.MediaType;
import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.RequestBody;
import okhttp3.Response;

public class MainActivity extends Activity {

    private static final String TAG = "MainActivity";
    private static final Gson gson = new Gson();
    private EditText idEditText;
    private Button createUserButton;
    private final OkHttpClient client = new OkHttpClient.Builder()
            .connectTimeout(30, java.util.concurrent.TimeUnit.SECONDS)
            .readTimeout(30, java.util.concurrent.TimeUnit.SECONDS)
            .writeTimeout(30, java.util.concurrent.TimeUnit.SECONDS)
            .build();

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main); // Set the layout for this activity

        idEditText = findViewById(R.id.token);
        createUserButton = findViewById(R.id.publish_button);

        checkToken();
    }

    public void onCreateUserButtonClick(@NonNull View view) {
        newRaiseUser(idEditText.getText().toString());
    }

    private void checkToken() {
        String token = getSharedPreferences("cdt", MODE_PRIVATE).getString("token", null);
        if (token == null) {
            Log.d(TAG, "No token found, performing login");
            Executors.newSingleThreadExecutor().execute(() -> {
                final Request.Builder builder = new Request.Builder().url("https://10.0.2.2:8443/login")
                        .post(RequestBody.create("{\"username\": \"admin\", \"password\": \"admin\"}",
                                MediaType.parse("application/json")));
                try (Response response = client.newCall(builder.build()).execute()) {
                    if (response.isSuccessful()) {
                        JsonObject responseBody = gson.fromJson(response.body().charStream(), JsonObject.class);
                        String new_token = responseBody.getAsJsonPrimitive("token").getAsString();
                        Log.d(TAG, "Login successful, token: " + new_token);
                        getSharedPreferences("cdt", MODE_PRIVATE).edit().putString("token", new_token).apply();
                        checkGoogleId();
                    } else
                        Log.e(TAG, "Login failed: " + response.code());
                } catch (Exception e) {
                    Log.e(TAG, "Error during login", e);
                }
            });
        } else {
            Log.d(TAG, "Token found in SharedPreferences: " + token);
            checkGoogleId();
        }
    }

    private void checkGoogleId() {
        String google_id = getSharedPreferences("cdt", MODE_PRIVATE).getString("google_id", null);
        if (google_id == null) {
            Log.d(TAG, "No Google ID found, please enter it.");
            createUserButton.setEnabled(true);
        } else {
            Log.d(TAG, "Google ID found in SharedPreferences: " + google_id);
            idEditText.setText(google_id);
            createUserButton.setEnabled(false);
            getRaiseUser(google_id);
        }
    }

    private void getRaiseUser(@NonNull String google_id) {
        final Request.Builder builder = new Request.Builder().url("https://10.0.2.2:8443/raise-users/" + google_id)
                .get();
        builder.addHeader("Authorization",
                "Bearer " + getSharedPreferences("cdt", MODE_PRIVATE).getString("token", null));
        Executors.newSingleThreadExecutor().execute(() -> {
            try (Response response = client.newCall(builder.build()).execute()) {
                if (response.isSuccessful()) {
                    String item_id = response.body().string();
                    getSharedPreferences("cdt", MODE_PRIVATE).edit().putString("item_id", item_id).apply();
                    checkFCMToken(item_id);
                } else if (response.code() == 404) {
                    Log.d(TAG, "User not found, creating new user");
                    newRaiseUser(google_id);
                } else
                    Log.e(TAG, "Failed to get user: " + response.code());
            } catch (Exception e) {
                Log.e(TAG, "Error during user retrieval", e);
            }
        });
    }

    private void newRaiseUser(@NonNull String google_id) {
        final Request.Builder builder = new Request.Builder().url("https://10.0.2.2:8443/raise-users")
                .post(RequestBody.create("{\"google_id\": \"" + google_id + "\"}",
                        MediaType.parse("application/json")));
        builder.addHeader("Authorization",
                "Bearer " + getSharedPreferences("cdt", MODE_PRIVATE).getString("token", null));
        Executors.newSingleThreadExecutor().execute(() -> {
            try (Response response = client.newCall(builder.build()).execute()) {
                if (response.isSuccessful()) {
                    String item_id = response.body().string();
                    getSharedPreferences("cdt", MODE_PRIVATE).edit()
                            .putString("google_id", google_id)
                            .putString("item_id", item_id).apply();
                    checkFCMToken(item_id);
                } else
                    Log.e(TAG, "Failed to create user: " + response.code());
            } catch (Exception e) {
                Log.e(TAG, "Error during user creation", e);
            }
        });
    }

    private void checkFCMToken(@NonNull String item_id) {
        FirebaseMessaging.getInstance().getToken().addOnCompleteListener(task -> {
            if (task.isSuccessful()) {
                Log.d(TAG, "FCM token retrieved successfully");
                String fcm_token = task.getResult();
                Log.d(TAG, "FCM Token: " + fcm_token);
                Executors.newSingleThreadExecutor().execute(() -> newFCMToken(item_id, fcm_token));
            } else
                Log.e("Connection", "Failed to get FCM token", task.getException());
        });
    }

    private void newFCMToken(@NonNull String item_id, @NonNull String fcm_token) {
        final Request.Builder builder = new Request.Builder().url("https://10.0.2.2:8443/fcm_tokens")
                .post(RequestBody.create("{\"id\": \"" + item_id + "\", \"token\": \"" + fcm_token + "\"}",
                        MediaType.parse("application/json")));
        builder.addHeader("Authorization",
                "Bearer " + getSharedPreferences("cdt", MODE_PRIVATE).getString("token", null));
        try (Response response = client.newCall(builder.build()).execute()) {
            if (response.isSuccessful()) {
                String responseBody = response.body().string();
                Log.d(TAG, "Token registered successfully: " + responseBody);
            } else
                Log.e(TAG, "Failed to register token: " + response.code());
        } catch (Exception e) {
            Log.e(TAG, "Error during token registration", e);
        }
    }
}
