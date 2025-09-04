package it.cnr.istc.coco;

import org.apache.hc.client5.http.classic.methods.HttpPost;
import org.apache.hc.client5.http.impl.classic.CloseableHttpClient;
import org.apache.hc.client5.http.impl.classic.HttpClients;
import org.apache.hc.core5.http.io.entity.EntityUtils;
import org.apache.hc.core5.http.io.entity.StringEntity;
import org.keycloak.events.Event;
import org.keycloak.events.EventListenerProvider;
import org.keycloak.events.EventType;
import org.keycloak.events.admin.AdminEvent;
import org.keycloak.events.admin.OperationType;
import org.keycloak.events.admin.ResourceType;

public class UserRegistrationListener implements EventListenerProvider {

    private static final String WEBHOOK_URL = System.getenv("COCO_API_URL");

    @Override
    public void close() {
    }

    @Override
    public void onEvent(Event event) {
        if (EventType.REGISTER.equals(event.getType()))
            create_user(event.getUserId());
    }

    @Override
    public void onEvent(AdminEvent event, boolean includeRepresentation) {
        if (OperationType.CREATE.equals(event.getOperationType()) && ResourceType.USER.equals(event.getResourceType()))
            create_user(event.getResourcePath().substring(event.getResourcePath().lastIndexOf('/') + 1));
    }

    private void create_user(String userId) {
        System.out.println("User created with ID: " + userId);
        try (CloseableHttpClient client = HttpClients.createDefault()) {
            HttpPost post = new HttpPost(WEBHOOK_URL + "/users");
            post.setHeader("Content-Type", "application/json");
            post.setEntity(new StringEntity("{\"keycloak_id\": \"" + userId + "\"}"));
            client.execute(post, response -> {
                if (response.getCode() != 201)
                    throw new RuntimeException("Failed to create user. Response code: " + response.getCode());
                String user_id = EntityUtils.toString(response.getEntity());
                System.out.println("User created with ID: " + user_id);
                return null;
            });
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
