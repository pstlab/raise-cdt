#pragma once

#include "mongo_db.hpp"
#include <pqxx/pqxx>

#define POSTGRES_URI(account, host, port) "postgresql://" account "@ " host ":" port "/raise_udp_db"

namespace cdt
{
  class raise_cdt_db : public coco::mongo_module
  {
  public:
    raise_cdt_db(coco::mongo_db &db) noexcept;

    /**
     * @brief Creates a new user entry in the database.
     *
     * @param keycloak_id The unique identifier for the user from Keycloak.
     * @param id The internal identifier for the user.
     */
    void create_user(std::string_view keycloak_id, std::string_view id);

    /**
     * @brief Retrieves the internal user identifier associated with the given Keycloak ID.
     *
     * This function queries the database to find the user corresponding to the provided
     * Keycloak identifier. If the user is found, their internal user identifier is returned as a string.
     *
     * @param keycloak_id The Keycloak ID used to identify the user.
     * @return std::string The internal user identifier associated with the Keycloak ID.
     */
    std::string get_user(std::string_view keycloak_id);

    /**
     * @brief Retrieves the Urban Data Platform data associated with a given Keycloak ID.
     *
     * This function queries the database to obtain Urban Data Platform (UDP) data
     * for the user identified by the provided Keycloak ID. The returned data is
     * formatted as a JSON object.
     *
     * @param keycloak_id The unique identifier of the user in Keycloak.
     * @return json::json A JSON object containing the user's Urban Data Platform data.
     */
    json::json get_urban_data_platform_data(std::string_view keycloak_id);

  private:
    mongocxx::collection users_collection;
    pqxx::connection pg_conn;
  };
} // namespace cdt
