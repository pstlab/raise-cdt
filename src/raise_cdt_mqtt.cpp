#include "raise_cdt_mqtt.hpp"
#include "logging.hpp"
#include <cassert>

namespace cdt
{
    raise_cdt_mqtt::raise_cdt_mqtt(coco::coco &cc, std::string_view mqtt_uri, std::string_view client_id) noexcept : coco_mqtt(cc, mqtt_uri, client_id), cdt::listener(static_cast<raise_cdt &>(cc.get_module<raise_cdt>())) {}

    void raise_cdt_mqtt::on_connect(const std::string &cause)
    {
        coco::coco_mqtt::on_connect(cause);
        for (auto &usr : get_coco().get_items(get_coco().get_type("RAISE-User")))
        {
            client.subscribe(COCO_NAME + std::string("/static/") + usr.get().get_properties()["google_id"].get<std::string>(), coco::QOS);
            client.subscribe(COCO_NAME + std::string("/dynamic/") + usr.get().get_properties()["google_id"].get<std::string>(), coco::QOS);
            LOG_DEBUG("Subscribed to topics for user with Google ID: " + usr.get().get_properties()["google_id"].get<std::string>());
        }
    }

    void raise_cdt_mqtt::on_message(mqtt::const_message_ptr msg)
    {
        coco::coco_mqtt::on_message(msg);
        if (msg->get_topic().find(COCO_NAME "/static/") == 0)
            get_coco().set_properties(static_cast<raise_cdt &>(get_coco().get_module<raise_cdt>()).get_user(msg->get_topic().substr(strlen(COCO_NAME "/static/"))), json::load(msg->to_string()));
        else if (msg->get_topic().find(COCO_NAME "/dynamic/") == 0)
            get_coco().set_value(static_cast<raise_cdt &>(get_coco().get_module<raise_cdt>()).get_user(msg->get_topic().substr(strlen(COCO_NAME "/dynamic/"))), json::load(msg->to_string()));
    }

    void raise_cdt_mqtt::created_user(std::string_view google_id, const coco::item &)
    {
        client.subscribe(COCO_NAME + std::string("/static/") + google_id.data(), coco::QOS);
        client.subscribe(COCO_NAME + std::string("/dynamic/") + google_id.data(), coco::QOS);
    }
} // namespace cdt
