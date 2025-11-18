#include "raise_cdt.hpp"
#include "raise_cdt_db.hpp"
#include "coco.hpp"
#include "logging.hpp"

namespace cdt
{
    raise_cdt::raise_cdt(coco::coco &cc) noexcept : coco_module(cc)
    {
        LOG_DEBUG("Initializing RAISE CDT module");
        LOG_DEBUG("Adding RAISE CDT database module");
        [[maybe_unused]] auto &db = get_coco().get_db().add_module<raise_cdt_db>(static_cast<coco::mongo_db &>(get_coco().get_db()));
        LOG_DEBUG("RAISE CDT module initialized");
    }

    coco::item &raise_cdt::create_user(std::string_view google_id)
    {
        auto &db = get_coco().get_db().get_module<raise_cdt_db>();
        auto &wrn = get_coco().create_item({get_coco().get_type(warning_kw)});
        auto &usr = get_coco().create_item({get_coco().get_type(user_kw)}, {{"google_id", google_id.data()}, {"warning_device", wrn.get_id()}});
        db.create_user(google_id, usr.get_id());
        CREATED_USER(google_id, usr);
        return usr;
    }

    coco::item &raise_cdt::get_user(std::string_view google_id)
    {
        auto &db = get_coco().get_db().get_module<raise_cdt_db>();
        std::string id = db.get_user(google_id);
        return get_coco().get_item(id);
    }

    void raise_cdt::created_user(std::string_view google_id, const coco::item &itm)
    {
        for (auto *listener : listeners)
            listener->created_user(google_id, itm);
    }

    listener::listener(raise_cdt &rcdt) noexcept : rcdt(rcdt) { rcdt.listeners.push_back(this); }
    listener::~listener() { rcdt.listeners.erase(std::remove(rcdt.listeners.begin(), rcdt.listeners.end(), this), rcdt.listeners.end()); }
} // namespace cdt
