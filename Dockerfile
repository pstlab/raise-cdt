# Use a base image with common dependencies pre-installed
FROM pstlab/coco-base:latest

# Expose the COCO application port
EXPOSE 8080

# Set environment variables for MongoDB connection
ARG MONGODB_HOST=coco-db
ARG MONGODB_PORT=27017
ARG CLIENT_DIR=/gui

# Clone and build RAISE-CDT
RUN git clone --recursive -b uncertainty https://github.com/pstlab/raise-cdt \
    && cd raise-cdt \
    && mkdir build && cd build \
    && cmake -DLOGGING_LEVEL=DEBUG -DMONGODB_HOST=${MONGODB_HOST} -DMONGODB_PORT=${MONGODB_PORT} -DCLIENT_DIR=${CLIENT_DIR} -DCMAKE_BUILD_TYPE=Release .. \
    && make -j$(nproc)

# Build the GUI application
RUN npm --prefix /raise-cdt/gui install && npm --prefix /raise-cdt/gui run build

# Move the built COCO files to the /app directory
RUN mv /raise-cdt/build/raise-cdt /cdt \
    && mv /raise-cdt/rules /rules \
    && mkdir -p /gui && mv /raise-cdt/gui/dist /gui \
    && rm -rf /raise-cdt

# Start the RAISE-CDT application
CMD ["./raise-cdt"]