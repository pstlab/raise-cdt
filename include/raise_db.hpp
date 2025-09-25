#pragma once
#include "coco_db.hpp"
#undef RANGE
#include <pqxx/pqxx>

#define POSTGRESQL_URI(account, password, host, port) "postgresql://" account ":" password "@" host ":" port "/raise_db"

namespace cdt
{
  struct raise_user
  {
    std::string id;
    json::json static_props;
  };

  class raise_db : public coco::db_module
  {
  public:
    raise_db(coco::coco_db &db, std::string_view postgresql_uri = POSTGRESQL_URI(POSTGRESQL_USER, POSTGRESQL_PASSWORD, POSTGRESQL_HOST, POSTGRESQL_PORT)) noexcept;

    /**
     * @brief Retrieves a list of all users from the database.
     *
     * This function queries the database to obtain a list of all users, returning
     * their internal identifiers and static properties as a vector of `raise_user` structures.
     *
     * @return std::vector<raise_user> A vector containing all users with their IDs and static properties.
     */
    std::vector<raise_user> get_users() noexcept;

    /**
     * @brief Retrieves the Urban Data Platform data associated with a given Google ID.
     *
     * This function queries the database to obtain Urban Data Platform (UDP) data
     * for the user identified by the provided Google ID. The returned data is
     * formatted as a JSON object.
     *
     * @param google_id The unique identifier of the user in Google.
     * @return json::json A JSON object containing the user's Urban Data Platform data.
     */
    json::json get_urban_data_platform_data(std::string_view google_id);

  private:
    pqxx::connection pg_conn;
  };
} // namespace cdt
