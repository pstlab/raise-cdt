#pragma once

#include "coco_module.hpp"
#include "coco_item.hpp"

#define CREATED_USER(keycloak_id, itm) created_user(keycloak_id, itm)

namespace cdt
{
  class listener;

  class raise_cdt : public coco::coco_module
  {
    friend class listener;

  public:
    raise_cdt(coco::coco &cc) noexcept;

    /**
     * @brief Creates a new user with the specified Keycloak ID and returns a reference to the corresponding coco::item.
     *
     * @param keycloak_id The Keycloak ID for the new user.
     * @return Reference to the newly created coco::item.
     * @throws May throw an exception if user creation fails.
     */
    coco::item &create_user(std::string_view keycloak_id);
    /**
     * @brief Retrieves a reference to a coco::item associated with the specified Keycloak ID.
     *
     * @param keycloak_id The Keycloak ID used to identify the user.
     * @return Reference to the corresponding coco::item.
     * @throws May throw an exception if the user is not found or retrieval fails.
     */
    coco::item &get_user(std::string_view keycloak_id);
    /**
     * @brief Updates the Urban Data Platform data for the user identified by the specified Keycloak ID.
     *
     * @param keycloak_id The Keycloak ID of the user whose UDP data is to be updated.
     * @throws May throw an exception if the update operation fails.
     */
    void update_udp_data(std::string_view keycloak_id);

  private:
    void created_user(std::string_view keycloak_id, const coco::item &itm);

  private:
    std::vector<listener *> listeners;
  };

  class listener
  {
    friend class raise_cdt;

  public:
    listener(raise_cdt &rcdt) noexcept;
    virtual ~listener();

  private:
    /**
     * @brief Notifies when the user item is created.
     *
     * @param keycloak_id The Keycloak ID for the new user.
     * @param itm The created user item.
     */
    virtual void created_user([[maybe_unused]] std::string_view keycloak_id, [[maybe_unused]] const coco::item &itm) {}

  private:
    raise_cdt &rcdt;
  };
} // namespace cdt
