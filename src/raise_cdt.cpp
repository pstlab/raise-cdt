#include "raise_cdt.hpp"
#include "raise_cdt_db.hpp"
#include "coco.hpp"

namespace cdt
{
    raise_cdt::raise_cdt(coco::coco &cc) noexcept : coco_module(cc)
    {
        get_coco().get_db().add_module<raise_cdt_db>(static_cast<coco::mongo_db &>(get_coco().get_db()));
    }

    coco::item &raise_cdt::create_user(std::string_view keycloak_id)
    {
        auto &db = get_coco().get_db().get_module<raise_cdt_db>();
        auto &usr = get_coco().create_item(get_coco().get_type("User"));
        db.create_user(keycloak_id, usr.get_id());
        return usr;
    }

    coco::item &raise_cdt::get_user(std::string_view keycloak_id)
    {
        auto &db = get_coco().get_db().get_module<raise_cdt_db>();
        std::string id = db.get_user(keycloak_id);
        return get_coco().get_item(id);
    }

    void raise_cdt::update_udp_data(std::string_view keycloak_id)
    {
        auto &db = get_coco().get_db().get_module<raise_cdt_db>();
        auto &usr = get_user(keycloak_id);
        json::json udp_data = db.get_urban_data_platform_data(keycloak_id);
        get_coco().set_value(usr, std::move(udp_data));
    }
} // namespace cdt
