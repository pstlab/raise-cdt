#pragma once

#include "coco_module.hpp"
#include "coco_item.hpp"

namespace cdt
{
  class raise_cdt : public coco::coco_module
  {
  public:
    raise_cdt(coco::coco &cc) noexcept;

    /**
     * @brief Creates a new user with the specified Keycloak ID.
     *
     * This function initializes a user entity using the provided Keycloak identifier.
     *
     * @param keycloak_id The unique identifier from Keycloak for the user.
     */
    void create_user(std::string_view keycloak_id);
    /**
     * @brief Retrieves a reference to a coco::item associated with the specified Keycloak ID.
     *
     * @param keycloak_id The Keycloak ID used to identify the user.
     * @return Reference to the corresponding coco::item.
     * @throws May throw an exception if the user is not found or retrieval fails.
     */
    coco::item &get_user(std::string_view keycloak_id);
  };
} // namespace cdt
