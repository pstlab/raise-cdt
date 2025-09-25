#include "raise_cdt.hpp"
#include "coco.hpp"
#include "mongo_db.hpp"
#ifdef BUILD_POSTGRESQL
#include "raise_db.hpp"
#endif
#include "coco_fcm.hpp"
#include "raise_cdt_mqtt.hpp"
#include "raise_cdt_server.hpp"
#include "coco_noauth.hpp"
#include "fcm_server.hpp"
#include "logging.hpp"
#ifdef ENABLE_CORS
#include "cors.hpp"
#endif
#include <mongocxx/instance.hpp>
#include <thread>

std::string read_rule(const std::string &path)
{
    std::ifstream file(path);
    if (!file.is_open())
        throw std::runtime_error("Could not open file: " + path);
    return std::string((std::istreambuf_iterator<char>(file)), std::istreambuf_iterator<char>());
}

int main()
{
    mongocxx::instance inst{}; // This should be done only once.
    LOG_INFO("Starting RAISE CDT...");
    coco::mongo_db db;
#ifdef BUILD_POSTGRESQL
    db.add_module<cdt::raise_db>(db);
#endif
    coco::coco cc(db);
    auto &cdt = cc.add_module<cdt::raise_cdt>(cc);
    auto &fcm = cc.add_module<coco::coco_fcm>(cc);

    try
    {
        [[maybe_unused]] auto &usr_tp = cc.get_type("User");
    }
    catch (const std::exception &e)
    {
        LOG_WARN("Initializing RAISE database");

        json::json static_props = {
            {"name", {{"type", "string"}}},
            {"keycloak_id", {{"type", "string"}}},
            {"training", {{"type", "bool"}, {"default", false}}},
            {"unavailable_states", {{"type", "bool"}, {"default", false}}},
            {"baseline_nutrition", {{"type", "bool"}, {"nullable", true}}},
            {"baseline_fall", {{"type", "int"}, {"min", 0}, {"max", 10}, {"nullable", true}}},
            //    "baseline_rehabilitation_school_load": {{"type": "bool"}, {"nullable", true}},
            //    "comorbidities": {{"type": "bool"}, {"nullable", true}},
            //    "bipolar_disorder_diagnosis": {{"type": "bool"}, {"nullable", true}},
            //    "disability_level": {{"type": "bool"}, {"nullable", true}},
            //    "intellectual_disability": {{"type": "bool"}, {"nullable", true}},
            //    "traumatic_events": {{"type": "bool"}, {"nullable", true}},
            {"baseline_freezing", {{"type", "int"}, {"min", 0}, {"max", 10}, {"nullable", true}}},
            {"baseline_heart_rate", {{"type", "int"}, {"min", 40}, {"max", 200}, {"nullable", true}}},
            //    "social_judgment": {{"type": "bool"}, {"nullable", true}},
            //    "motor_deficit_level": {{"type": "bool"}, {"nullable", true}},
            //    "agoraphobia_avoidance_symptoms": {{"type": "bool"}, {"nullable", true}},
            //    "panic_attacks_anticipatory_anxiety": {{"type": "bool"}, {"nullable", true}},
            //    "somatoform_disorders": {{"type": "bool"}, {"nullable", true}},
            //    "social_phobia": {{"type": "bool"}, {"nullable", true}},
            {"state_anxiety_presence", {{"type", "int"}, {"min", 0}, {"max", 10}, {"nullable", true}}},
            {"baseline_blood_pressure", {{"type", "int"}, {"min", 40}, {"max", 200}, {"nullable", true}}},
            {"sensory_profile", {{"type", "bool"}, {"nullable", true}}},
            {"stress", {{"type", "int"}, {"min", 0}, {"max", 10}, {"nullable", true}}},
            {"psychiatric_disorders", {{"type", "bool"}, {"nullable", true}}},
            //    "personality_traits": {{"type": "bool"}, {"nullable", true}},
            {"parkinson", {{"type", "bool"}, {"nullable", true}}},
            {"older_adults", {{"type", "bool"}, {"nullable", true}}},
            {"psychiatric_patients", {{"type", "bool"}, {"nullable", true}}},
            {"multiple_sclerosis", {{"type", "bool"}, {"nullable", true}}},
            {"young_pci_autism", {{"type", "bool"}, {"nullable", true}}}};

        json::json dynamic_props = {
            {"EXCESSIVE_HEAT", {{"type", "symbol"}, {"values", {"low", "medium", "high"}}, {"default", "low"}}},
            {"excessive_heat_relevant", {{"type", "symbol"}, {"multiple", true}, {"values", {"water_balance", "heart_rate", "baseline_heart_rate", "heart_rate_differential", "galvanic_skin_response", "baseline_blood_pressure", "low_blood_pressure", "sweating", "body_temperature"}}}},
            {"ANXIETY", {{"type", "symbol"}, {"values", {"low", "medium", "high"}}, {"default", "low"}}},
            {"anxiety_relevant", {{"type", "symbol"}, {"multiple", true}, {"values", {"baseline_freezing", "recent_freezing_episodes", "heart_rate", "baseline_heart_rate", "heart_rate_differential", "respiratory_rate", "galvanic_skin_response", "high_blood_pressure", "self_perception", "sweating", "body_temperature"}}}},
            {"MENTAL_FATIGUE", {{"type", "symbol"}, {"values", {"low", "medium", "high"}}, {"default", "low"}}},
            {"PHYSICAL_FATIGUE", {{"type", "symbol"}, {"values", {"low", "medium", "high"}}, {"default", "low"}}},
            {"physical_fatigue_relevant", {{"type", "symbol"}, {"multiple", true}, {"values", {"bar_restaurant", "water_fountains", "heart_rate", "baseline_heart_rate", "respiratory_rate", "sittings", "restroom_availability", "green_spaces"}}}},
            {"SENSORY_DYSREGULATION", {{"type", "symbol"}, {"values", {"low", "medium", "high"}}, {"default", "low"}}},
            {"sensory_dysregulation_relevant", {{"type", "symbol"}, {"multiple", true}, {"values", {"heart_rate", "baseline_heart_rate", "respiratory_rate", "sensory_profile"}}}},
            {"FREEZING", {{"type", "symbol"}, {"values", {"low", "medium", "high"}}, {"default", "low"}}},
            {"freezing_relevant", {{"type", "symbol"}, {"multiple", true}, {"values", {"heart_rate_differential"}}}},
            {"FLUCTUATION", {{"type", "symbol"}, {"values", {"low", "medium", "high"}}, {"default", "low"}}},
            {"DYSKINESIA", {{"type", "symbol"}, {"values", {"low", "medium", "high"}}, {"default", "low"}}},
            {"crowding", {{"type", "int"}, {"min", 0}, {"max", 100}, {"nullable", true}}},
            {"altered_nutrition", {{"type", "bool"}, {"nullable", true}}},
            {"altered_thirst_perception", {{"type", "int"}, {"min", 0}, {"max", 10}, {"nullable", true}}},
            {"bar_restaurant", {{"type", "bool"}, {"nullable", true}}},
            {"architectural_barriers", {{"type", "bool"}, {"nullable", true}}},
            {"water_balance", {{"type", "int"}, {"min", -10}, {"max", 10}, {"nullable", true}}},
            //    "fall": {{"type": "bool"}, {"nullable", true}},
            //    "attention_capacity": {{"type": "bool"}, {"nullable", true}},
            {"sleep_duration_quality", {{"type", "int"}, {"min", 0}, {"max", 10}, {"nullable", true}}},
            //    "engagement_in_adl": {{"type": "bool"}, {"nullable", true}},
            {"water_fountains", {{"type", "bool"}, {"nullable", true}}},
            {"recent_freezing_episodes", {{"type", "int"}, {"min", 0}, {"max", 10}, {"nullable", true}}},
            {"heart_rate", {{"type", "int"}, {"min", 40}, {"max", 200}, {"nullable", true}}},
            {"heart_rate_differential", {{"type", "int"}, {"min", -50}, {"max", 50}, {"nullable", true}}},
            {"public_events_frequency", {{"type", "bool"}, {"nullable", true}}},
            {"respiratory_rate", {{"type", "int"}, {"min", 8}, {"max", 50}, {"nullable", true}}},
            {"galvanic_skin_response", {{"type", "int"}, {"min", 0}, {"max", 20}, {"nullable", true}}},
            {"lighting", {{"type", "bool"}, {"nullable", true}}},
            {"noise_pollution", {{"type", "int"}, {"min", 30}, {"max", 120}, {"nullable", true}}},
            {"user_reported_noise_pollution", {{"type", "int"}, {"min", 0}, {"max", 10}, {"nullable", true}}},
            {"air_pollution", {{"type", "int"}, {"min", 0}, {"max", 500}, {"nullable", true}}},
            {"traffic_levels", {{"type", "int"}, {"min", 0}, {"max", 100}, {"nullable", true}}},
            {"lack_of_ventilation", {{"type", "int"}, {"min", 0}, {"max", 10}, {"nullable", true}}},
            //    "daily_steps": {{"type": "bool"}, {"nullable", true}},
            //    "rehabilitation_school_load": {{"type": "bool"}, {"nullable", true}},
            //    "heat_waves": {{"type": "bool"}, {"nullable", true}},
            {"path_slope", {{"type", "bool"}, {"nullable", true}}},
            {"safety_perception", {{"type", "bool"}, {"nullable", true}}},
            //    "fatigue_perception": {{"type": "bool"}, {"nullable", true}},
            {"rough_path", {{"type", "bool"}, {"nullable", true}}},
            {"public_events_presence", {{"type", "bool"}, {"nullable", true}}},
            // Systolic?
            {"high_blood_pressure", {{"type", "int"}, {"min", 90}, {"max", 200}, {"nullable", true}}},
            // Diastolic?
            {"low_blood_pressure", {{"type", "int"}, {"min", 40}, {"max", 120}, {"nullable", true}}},
            {"social_pressure", {{"type", "bool"}, {"nullable", true}}},
            {"sittings", {{"type", "bool"}, {"nullable", true}}},
            {"self_perception", {{"type", "bool"}, {"nullable", true}}},
            {"restroom_availability", {{"type", "bool"}, {"nullable", true}}},
            {"sweating", {{"type", "int"}, {"min", 0}, {"max", 10}, {"nullable", true}}},
            {"ambient_temperature", {{"type", "float"}, {"min", -30}, {"max", 50}, {"nullable", true}}},
            {"body_temperature", {{"type", "float"}, {"min", 35}, {"max", 42}, {"nullable", true}}},
            {"ambient_humidity", {{"type", "int"}, {"min", 0}, {"max", 100}, {"nullable", true}}},
            {"excessive_urbanization", {{"type", "bool"}, {"nullable", true}}},
            {"green_spaces", {{"type", "bool"}, {"nullable", true}}}};
        [[maybe_unused]] auto &usr_tp = cc.create_type("User", {}, std::move(static_props), std::move(dynamic_props));

        cc.create_reactive_rule("anxiety", read_rule("rules/anxiety.clp"));
        cc.create_reactive_rule("dyskinesia", read_rule("rules/dyskinesia.clp"));
        cc.create_reactive_rule("excessive_heat", read_rule("rules/excessive_heat.clp"));
        cc.create_reactive_rule("fluctuation", read_rule("rules/fluctuation.clp"));
        cc.create_reactive_rule("freezing", read_rule("rules/freezing.clp"));
        cc.create_reactive_rule("mental_fatigue", read_rule("rules/mental_fatigue.clp"));
        cc.create_reactive_rule("physical_fatigue", read_rule("rules/physical_fatigue.clp"));
        cc.create_reactive_rule("sensory_dysregulation", read_rule("rules/sensory_dysregulation.clp"));
    }

    auto &mqtt = cc.add_module<cdt::raise_cdt_mqtt>(cc);
    do
    {
        std::this_thread::sleep_for(std::chrono::seconds(2)); // wait for mqtt to connect
    } while (!mqtt.is_connected());
    cc.init();

    coco::coco_server srv(cc);
#ifdef ENABLE_CORS
    srv.add_middleware<network::cors>(srv);
#endif
    srv.add_module<coco::server_noauth>(srv);
    srv.add_module<cdt::raise_cdt_server>(srv, cdt);
    srv.add_module<coco::fcm_server>(srv, fcm);
    auto srv_ft = std::async(std::launch::async, [&srv]
                             { srv.start(); });

    return 0;
}
