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
  - Build the Keycloak event listener provider:
    ```bash
    mvn -f keycloak/pom.xml clean package
    ```
  - Create a `.env` file from `.env.example` and configure your environment variables.
  - Adjust the `compose.yaml` file to customize service settings as needed.
3. **Start the services**:
  ```bash
  docker compose up -d
  ```

Access the pgAdmin interface at `http://localhost:5050` (default credentials: `admin@local.it` / `admin`).  
Run `test_db.sql` in pgAdmin to initialize the database schema.

Enable the Keycloak user registration listener by logging into the Keycloak admin console at `https://localhost:8081` (default credentials: `admin` / `admin`), Realm settings -> Events -> Event listeners -> add `user-registration-listener`.