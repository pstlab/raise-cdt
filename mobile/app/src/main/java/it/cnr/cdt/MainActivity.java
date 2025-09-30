package it.cnr.cdt;

import android.app.Activity;
import android.app.NotificationChannel;
import android.app.NotificationManager;
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
    private EditText googleIdEditText;
    private Button connectUserButton, createUserButton, logoutButton;
    private final OkHttpClient client = new OkHttpClient.Builder()
            .connectTimeout(30, java.util.concurrent.TimeUnit.SECONDS)
            .readTimeout(30, java.util.concurrent.TimeUnit.SECONDS)
            .writeTimeout(30, java.util.concurrent.TimeUnit.SECONDS)
            .build();

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main); // Set the layout for this activity

        NotificationChannel channel = new NotificationChannel("default_channel", "Default Channel",
                NotificationManager.IMPORTANCE_HIGH);
        channel.setDescription("Channel for FCM notifications");

        NotificationManager manager = getSystemService(NotificationManager.class);
        manager.createNotificationChannel(channel);

        googleIdEditText = findViewById(R.id.google_id);
        connectUserButton = findViewById(R.id.connect_button);
        createUserButton = findViewById(R.id.create_button);
        logoutButton = findViewById(R.id.logout_button);

        checkToken();
    }

    public void onConnectUserButtonClick(@NonNull View view) {
        getRaiseUser(googleIdEditText.getText().toString());
    }

    public void onCreateUserButtonClick(@NonNull View view) {
        newRaiseUser(googleIdEditText.getText().toString());
    }

    public void onLogoutButtonClick(@NonNull View view) {
        getSharedPreferences("cdt", MODE_PRIVATE).edit().remove("token").remove("google_id").remove("item_id").apply();
        googleIdEditText.setText("");
        googleIdEditText.setEnabled(true);
        connectUserButton.setEnabled(true);
        createUserButton.setEnabled(true);
        logoutButton.setEnabled(false);
        checkToken();
    }

    /**
     * Checks for the presence of an authentication token in SharedPreferences.
     *
     * If the token is not found, performs a login request to the server using
     * hardcoded credentials, retrieves the token from the response, saves it in
     * SharedPreferences, and proceeds to check the Google ID.
     * If the token is already present, logs its value and proceeds to check the
     * Google ID.
     *
     * Network operations are performed on a background thread.
     * Logs relevant information and errors for debugging purposes.
     */
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

    /**
     * Checks for the presence of a Google ID in SharedPreferences.
     *
     * If the Google ID is not found, enables the buttons for user connection
     * and creation, allowing the user to input their Google ID.
     * If the Google ID is found, populates the corresponding EditText field,
     * disables the user creation button, and initiates a request to retrieve
     * the associated user data from the server.
     *
     * Logs relevant information for debugging purposes.
     */
    private void checkGoogleId() {
        String google_id = getSharedPreferences("cdt", MODE_PRIVATE).getString("google_id", null);
        if (google_id == null) {
            Log.d(TAG, "No Google ID found, please enter it.");
            googleIdEditText.setText("");
            googleIdEditText.setEnabled(true);
            connectUserButton.setEnabled(true);
            createUserButton.setEnabled(true);
            logoutButton.setEnabled(false);
        } else {
            Log.d(TAG, "Google ID found in SharedPreferences: " + google_id);
            googleIdEditText.setText(google_id);
            googleIdEditText.setEnabled(false);
            connectUserButton.setEnabled(false);
            createUserButton.setEnabled(false);
            logoutButton.setEnabled(true);
            getRaiseUser(google_id);
        }
    }

    /**
     * Retrieves a user from the server using their Google ID.
     * 
     * If the user is found, their item ID is saved in SharedPreferences,
     * and the FCM token is checked and potentially registered.
     * If the user is not found (404 response), a new user is created.
     * 
     * Network operations are performed on a background thread.
     * Logs relevant information and errors for debugging purposes.
     */
    private void getRaiseUser(@NonNull String google_id) {
        final Request.Builder builder = new Request.Builder().url("https://10.0.2.2:8443/raise-users/" + google_id)
                .get();
        builder.addHeader("Authorization",
                "Bearer " + getSharedPreferences("cdt", MODE_PRIVATE).getString("token", null));
        Executors.newSingleThreadExecutor().execute(() -> {
            try (Response response = client.newCall(builder.build()).execute()) {
                if (response.isSuccessful()) {
                    JsonObject responseBody = gson.fromJson(response.body().charStream(), JsonObject.class);
                    String item_id = responseBody.getAsJsonPrimitive("id").getAsString();
                    getSharedPreferences("cdt", MODE_PRIVATE).edit()
                            .putString("google_id", google_id)
                            .putString("item_id", item_id).apply();
                    runOnUiThread(() -> {
                        googleIdEditText.setEnabled(false);
                        connectUserButton.setEnabled(false);
                        createUserButton.setEnabled(false);
                        logoutButton.setEnabled(true);
                    });
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

    /**
     * Creates a new user on the server with the provided Google ID.
     * 
     * If the user is successfully created, their Google ID and item ID
     * are saved in SharedPreferences, and the FCM token is checked and
     * potentially registered.
     * 
     * Network operations are performed on a background thread.
     * Logs relevant information and errors for debugging purposes.
     */
    private void newRaiseUser(@NonNull String google_id) {
        final Request.Builder builder = new Request.Builder().url("https://10.0.2.2:8443/raise-users")
                .post(RequestBody.create("{\"google_id\": \"" + google_id + "\"}",
                        MediaType.parse("application/json")));
        builder.addHeader("Authorization",
                "Bearer " + getSharedPreferences("cdt", MODE_PRIVATE).getString("token", null));
        Executors.newSingleThreadExecutor().execute(() -> {
            try (Response response = client.newCall(builder.build()).execute()) {
                if (response.isSuccessful()) {
                    JsonObject responseBody = gson.fromJson(response.body().charStream(), JsonObject.class);
                    String item_id = responseBody.getAsJsonPrimitive("id").getAsString();
                    getSharedPreferences("cdt", MODE_PRIVATE).edit()
                            .putString("google_id", google_id)
                            .putString("item_id", item_id).apply();
                    runOnUiThread(() -> {
                        googleIdEditText.setEnabled(false);
                        connectUserButton.setEnabled(false);
                        createUserButton.setEnabled(false);
                        logoutButton.setEnabled(true);
                    });
                    checkFCMToken(item_id);
                } else
                    Log.e(TAG, "Failed to create user: " + response.code());
            } catch (Exception e) {
                Log.e(TAG, "Error during user creation", e);
            }
        });
    }

    /**
     * Checks and registers the FCM token for the user with the given item ID.
     * 
     * Retrieves the current FCM token and sends it to the server to be
     * associated with the user's item ID.
     * 
     * Network operations are performed on a background thread.
     * Logs relevant information and errors for debugging purposes.
     */
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

    /**
     * Registers a new FCM token for the user with the given item ID.
     * 
     * Sends the FCM token to the server to be associated with the user's
     * item ID.
     * 
     * Network operations are performed on a background thread.
     * Logs relevant information and errors for debugging purposes.
     */
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
