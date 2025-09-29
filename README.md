# RAISE Citizen Digital Twin

The **Citizen Digital Twin** is part of the [**RAISE project**](https://www.raiseliguria.it), aiming to design and implement innovative models for simulating, representing, and analyzing citizens’ interactions with urban and social environments.  
This repository provides the foundations for developing **Citizen Digital Twins (CDTs)**, enabling data-driven decision support, participatory governance, and improved citizen well-being.

## How to use this repository

1. **Clone the repository**:
  ```bash
  git clone https://github.com/pstlab/raise-cdt
  cd raise-cdt
  ```
2. **Set up the environment**:
  - Create a `.env` file from `.env.example` and configure your environment variables.
  - Adjust the `compose.yaml` file to customize service settings as needed.
  - Create a self-signed SSL certificate for secure communication:
    ```bash
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout key.pem -out cert.pem \
    -subj "/CN=10.0.2.2" \
    -addext "subjectAltName=IP:10.0.2.2"
    ```
3. **Start the services**:
  ```bash
  docker compose up -d
  ```