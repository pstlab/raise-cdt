FROM quay.io/keycloak/keycloak:latest
# copy your event listener provider jar (built elsewhere) into Keycloak providers folder
COPY target/keycloak-1.0-SNAPSHOT.jar /opt/keycloak/providers/

# for demonstration purposes only, please make sure to use proper certificates in production instead
WORKDIR /opt/keycloak
RUN keytool -genkeypair -storepass password -storetype PKCS12 -keyalg RSA -keysize 2048 -dname "CN=server" -alias server -ext "SAN:c=DNS:localhost,IP:127.0.0.1" -keystore conf/server.keystore
RUN /opt/keycloak/bin/kc.sh build

# keep same startup behavior
ENTRYPOINT [ "/opt/keycloak/bin/kc.sh" ]
CMD ["start"]