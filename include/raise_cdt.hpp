#pragma once

#include "coco_module.hpp"
#include "coco_item.hpp"

#define CREATED_USER(google_id, itm) created_user(google_id, itm)

namespace cdt
{
  class listener;

  constexpr const char *user_kw = "RAISE-User";
  constexpr const char *warning_kw = "RAISE-Warning";

  class raise_cdt : public coco::coco_module
  {
    friend class listener;

  public:
    raise_cdt(coco::coco &cc) noexcept;

    /**
     * @brief Creates a new user with the specified Google ID and returns a reference to the corresponding coco::item.
     *
     * @param google_id The Google ID for the new user.
     * @return Reference to the newly created coco::item.
     * @throws May throw an exception if user creation fails.
     */
    coco::item &create_user(std::string_view google_id);
    /**
     * @brief Retrieves a reference to a coco::item associated with the specified Google ID.
     *
     * @param google_id The Google ID used to identify the user.
     * @return Reference to the corresponding coco::item.
     * @throws May throw an exception if the user is not found or retrieval fails.
     */
    coco::item &get_user(std::string_view google_id);

  private:
    void created_user(std::string_view google_id, const coco::item &itm);

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
     * @param google_id The Google ID for the new user.
     * @param itm The created user item.
     */
    virtual void created_user([[maybe_unused]] std::string_view google_id, [[maybe_unused]] const coco::item &itm) {}

  private:
    raise_cdt &rcdt;
  };
} // namespace cdt
