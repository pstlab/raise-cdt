# Use a base image with common dependencies pre-installed
FROM pstlab/coco-base:latest

# Install the necessary dependencies
RUN apt update && apt install -y libpqxx-dev

# Expose the COCO application port
EXPOSE 8080

# Set environment variables for MongoDB connection
ARG MONGODB_HOST=raise-cdt-db
ARG MONGODB_PORT=27017
ARG POSTGRES_HOST=raise-udp-db
ARG POSTGRES_PORT=5432
ARG POSTGRES_USER=account
ARG POSTGRES_PASSWORD=yourpassword
ARG MQTT_HOST=raise-mqtt
ARG MQTT_PORT=1883
ARG CLIENT_DIR=/gui

# Clone and build RAISE-CDT
RUN git clone --recursive https://github.com/pstlab/raise-cdt \
    && cd raise-cdt \
    && mkdir build && cd build \
    && cmake -DLOGGING_LEVEL=DEBUG -DMONGODB_HOST=${MONGODB_HOST} -DMONGODB_PORT=${MONGODB_PORT} -DPOSTGRES_HOST=${POSTGRES_HOST} -DPOSTGRES_PORT=${POSTGRES_PORT} -DPOSTGRES_USER=${POSTGRES_USER} -DPOSTGRES_PASSWORD=${POSTGRES_PASSWORD} -DMQTT_HOST=${MQTT_HOST} -DMQTT_PORT=${MQTT_PORT} -DCLIENT_DIR=${CLIENT_DIR} -DCMAKE_BUILD_TYPE=Release .. \
    && make -j$(nproc)

# Build the GUI application
RUN npm --prefix /raise-cdt/gui install && npm --prefix /raise-cdt/gui run build

# Move the built COCO files to the /app directory
RUN mv /raise-cdt/build/raise-cdt /cdt \
    && mv /raise-cdt/rules /rules \
    && mkdir -p /gui && mv /raise-cdt/gui/dist /gui \
    && rm -rf /raise-cdt

# Start the RAISE-CDT application
CMD ["/cdt"]