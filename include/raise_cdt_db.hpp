#pragma once

#include "mongo_db.hpp"

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

  private:
    mongocxx::collection users_collection;
  };
} // namespace cdt
