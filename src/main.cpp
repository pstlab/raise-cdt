#include "RAISE_CDT_config.hpp"
#include "raise_cdt.hpp"
#include "coco.hpp"
#include "mongo_db.hpp"
#ifdef BUILD_LLM
#include "coco_llm.hpp"
#endif
#ifdef BUILD_FCM
#include "coco_fcm.hpp"
#endif
#include "raise_cdt_mqtt.hpp"
#include "raise_cdt_server.hpp"
#ifdef BUILD_FCM
#include "fcm_server.hpp"
#endif
#include "logging.hpp"
#include <mongocxx/instance.hpp>
#include <thread>

int main()
{
    mongocxx::instance inst{}; // This should be done only once.
    LOG_INFO("Starting RAISE CDT...");
    coco::mongo_db db;
    LOG_DEBUG("Connected to MongoDB database");
    LOG_DEBUG("Initializing CoCo framework");
    coco::coco cc(db);
    LOG_DEBUG("Adding RAISE CDT module");
    auto &cdt = cc.add_module<cdt::raise_cdt>(cc);
#ifdef BUILD_LLM
    LOG_DEBUG("Adding CoCo LLM module");
    cc.add_module<coco::coco_llm>(cc);
#endif
#ifdef BUILD_FCM
    LOG_DEBUG("Adding CoCo FCM module");
    auto fcm_project_id = std::getenv("FCM_PROJECT_ID");
    if (fcm_project_id)
        LOG_DEBUG("FCM Project ID: " + std::string(fcm_project_id));
    else
        LOG_WARN("FCM Project ID not set");
    auto client_email = std::getenv("FCM_CLIENT_EMAIL");
    if (client_email)
        LOG_DEBUG("FCM Client Email: " + std::string(client_email));
    else
        LOG_WARN("FCM Client Email not set");
    auto private_key = std::getenv("FCM_PRIVATE_KEY");
    if (private_key)
        LOG_DEBUG("FCM Private Key is set");
    else
        LOG_WARN("FCM Private Key not set");
    std::this_thread::sleep_for(std::chrono::seconds(1));
    auto &fcm = cc.add_module<coco::coco_fcm>(cc);
#endif

    LOG_DEBUG("Loading RAISE CDT configuration");
    load_config(cc);

    // LOG_DEBUG("Adding RAISE CDT MQTT module");
    // auto &mqtt = cc.add_module<cdt::raise_cdt_mqtt>(cc);
    // do
    // { // wait for mqtt to connect
    //     std::this_thread::sleep_for(std::chrono::seconds(1));
    // } while (!mqtt.is_connected());

    LOG_INFO("Starting RAISE CDT server...");
    coco::coco_server srv(cc);
#ifdef BUILD_SECURE
    const char *cert = std::getenv("RAISE_CDT_CERT");
    const char *key = std::getenv("RAISE_CDT_KEY");
    srv.load_certificate(cert, key);
#endif
    LOG_DEBUG("Adding RAISE CDT server module");
    srv.add_module<cdt::raise_cdt_server>(srv, cdt);
#ifdef BUILD_FCM
    LOG_DEBUG("Adding FCM server module");
    srv.add_module<coco::fcm_server>(srv, fcm);
#endif
    auto srv_ft = std::async(std::launch::async, [&srv]
                             { srv.start(); });

#ifdef INTERACTIVE_TEST
    std::string user_input;
    std::cin >> user_input;
    if (user_input == "d")
    {
        db.drop();
        srv.stop();
    }
#endif

    return 0;
}
