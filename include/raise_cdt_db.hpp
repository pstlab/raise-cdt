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
     * @param google_id The unique identifier for the user from Google.
     * @param id The internal identifier for the user.
     */
    void create_user(std::string_view google_id, std::string_view id);

    /**
     * @brief Retrieves the internal user identifier associated with the given Google ID.
     *
     * This function queries the database to find the user corresponding to the provided
     * Google identifier. If the user is found, their internal user identifier is returned as a string.
     *
     * @param google_id The Google ID used to identify the user.
     * @return std::string The internal user identifier associated with the Google ID.
     */
    std::string get_user(std::string_view google_id);

    /**
     * @brief Checks if a user exists in the database based on their Google ID.
     *
     * This function queries the database to determine if a user with the specified
     * Google identifier exists. It returns true if the user is found, and false otherwise.
     *
     * @param google_id The Google ID used to identify the user.
     * @return bool True if the user exists, false otherwise.
     */
    bool user_exists(std::string_view google_id);

  private:
    mongocxx::collection users_collection;
  };
} // namespace cdt
