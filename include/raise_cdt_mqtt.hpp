#pragma once

#include "coco_mqtt.hpp"
#include "raise_cdt.hpp"

namespace cdt
{
  class raise_cdt_mqtt : public coco::coco_mqtt, public listener
  {
  public:
    raise_cdt_mqtt(coco::coco &cc, std::string_view mqtt_uri = MQTT_URI(MQTT_HOST, MQTT_PORT), std::string_view client_id = COCO_NAME) noexcept;

  private:
    void on_connect(const std::string &cause) override;
    void on_message(mqtt::const_message_ptr msg) override;

    void created_user(std::string_view keycloak_id, const coco::item &itm) override;
  };
} // namespace cdt
