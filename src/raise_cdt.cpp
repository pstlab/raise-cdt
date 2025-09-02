#include "raise_cdt.hpp"
#include "raise_cdt_db.hpp"
#include "coco.hpp"
#include "logging.hpp"

namespace cdt
{
    raise_cdt::raise_cdt(coco::coco &cc) noexcept : coco_module(cc)
    {
        auto &db = get_coco().get_db().add_module<raise_cdt_db>(static_cast<coco::mongo_db &>(get_coco().get_db()));
        for (auto &usr : db.get_users())
            if (!db.user_exists(usr.id))
                create_user(usr.id);
    }

    coco::item &raise_cdt::create_user(std::string_view keycloak_id)
    {
        auto &db = get_coco().get_db().get_module<raise_cdt_db>();
        auto &usr = get_coco().create_item(get_coco().get_type("User"), {{"keycloak_id", keycloak_id.data()}});
        db.create_user(keycloak_id, usr.get_id());
        CREATED_USER(keycloak_id, usr);
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

    void raise_cdt::created_user(std::string_view keycloak_id, const coco::item &itm)
    {
        for (auto *listener : listeners)
            listener->created_user(keycloak_id, itm);
    }

    listener::listener(raise_cdt &rcdt) noexcept : rcdt(rcdt) { rcdt.listeners.push_back(this); }
    listener::~listener() { rcdt.listeners.erase(std::remove(rcdt.listeners.begin(), rcdt.listeners.end(), this), rcdt.listeners.end()); }
} // namespace cdt
