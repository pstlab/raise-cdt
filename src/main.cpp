#include "raise_cdt.hpp"
#include "coco.hpp"
#include "mongo_db.hpp"
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
    coco::mongo_db db;
    coco::coco cc(db);
    auto &cdt = cc.add_module<cdt::raise_cdt>(cc);
    auto &fcm = cc.add_module<coco::coco_fcm>(cc);
    cc.add_module<cdt::raise_cdt_mqtt>(cc);
    cc.init();

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
            {"baseline_nutrition", {{"type", "bool"}}},
            {"baseline_fall", {{"type", "int"}, {"min", 0}, {"max", 10}}},
            //    "baseline_rehabilitation_school_load": {"type": "bool"},
            //    "comorbidities": {"type": "bool"},
            //    "bipolar_disorder_diagnosis": {"type": "bool"},
            //    "disability_level": {"type": "bool"},
            //    "intellectual_disability": {"type": "bool"},
            //    "traumatic_events": {"type": "bool"},
            {"baseline_freezing", {{"type", "int"}, {"min", 0}, {"max", 10}}},
            {"baseline_heart_rate", {{"type", "int"}, {"min", 40}, {"max", 200}}},
            //    "social_judgment": {"type": "bool"},
            //    "motor_deficit_level": {"type": "bool"},
            //    "agoraphobia_avoidance_symptoms": {"type": "bool"},
            //    "panic_attacks_anticipatory_anxiety": {"type": "bool"},
            //    "somatoform_disorders": {"type": "bool"},
            //    "social_phobia": {"type": "bool"},
            {"state_anxiety_presence", {{"type", "int"}, {"min", 0}, {"max", 10}}},
            {"baseline_blood_pressure", {{"type", "int"}, {"min", 40}, {"max", 200}}},
            {"sensory_profile", {{"type", "bool"}}},
            {"stress", {{"type", "int"}, {"min", 0}, {"max", 10}}},
            {"psychiatric_disorders", {{"type", "bool"}}},
            //    "personality_traits": {"type": "bool"},
            {"parkinson", {{"type", "bool"}}},
            {"older_adults", {{"type", "bool"}}},
            {"psychiatric_patients", {{"type", "bool"}}},
            {"multiple_sclerosis", {{"type", "bool"}}},
            {"young_pci_autism", {{"type", "bool"}}}};

        json::json dynamic_props = {
            {"EXCESSIVE_HEAT", {{"type", "symbol"}, {"values", {"low", "medium", "high"}}}},
            {"excessive_heat_relevant", {{"type", "symbol"}, {"multiple", true}, {"values", {"water_balance", "heart_rate", "baseline_heart_rate", "heart_rate_differential", "galvanic_skin_response", "baseline_blood_pressure", "low_blood_pressure", "sweating", "body_temperature"}}}},
            {"ANXIETY", {{"type", "symbol"}, {"values", {"low", "medium", "high"}}}},
            {"anxiety_relevant", {{"type", "symbol"}, {"multiple", true}, {"values", {"baseline_freezing", "recent_freezing_episodes", "heart_rate", "baseline_heart_rate", "heart_rate_differential", "respiratory_rate", "galvanic_skin_response", "high_blood_pressure", "self_perception", "sweating", "body_temperature"}}}},
            {"MENTAL_FATIGUE", {{"type", "symbol"}, {"values", {"low", "medium", "high"}}}},
            {"PHYSICAL_FATIGUE", {{"type", "symbol"}, {"values", {"low", "medium", "high"}}}},
            {"physical_fatigue_relevant", {{"type", "symbol"}, {"multiple", true}, {"values", {"bar_restaurant", "water_fountains", "heart_rate", "baseline_heart_rate", "respiratory_rate", "sittings", "restroom_availability", "green_spaces"}}}},
            {"SENSORY_DYSREGULATION", {{"type", "symbol"}, {"values", {"low", "medium", "high"}}}},
            {"sensory_dysregulation_relevant", {{"type", "symbol"}, {"multiple", true}, {"values", {"heart_rate", "baseline_heart_rate", "respiratory_rate", "sensory_profile"}}}},
            {"FREEZING", {{"type", "symbol"}, {"values", {"low", "medium", "high"}}}},
            {"freezing_relevant", {{"type", "symbol"}, {"multiple", true}, {"values", {"heart_rate_differential"}}}},
            {"FLUCTUATION", {{"type", "symbol"}, {"values", {"low", "medium", "high"}}}},
            {"DYSKINESIA", {{"type", "symbol"}, {"values", {"low", "medium", "high"}}}},
            {"crowding", {{"type", "int"}, {"min", 0}, {"max", 100}}},
            {"altered_nutrition", {{"type", "bool"}}},
            {"altered_thirst_perception", {{"type", "int"}, {"min", 0}, {"max", 10}}},
            {"bar_restaurant", {{"type", "bool"}}},
            {"architectural_barriers", {{"type", "bool"}}},
            {"water_balance", {{"type", "int"}, {"min", -10}, {"max", 10}}},
            //    "fall": {"type": "bool"},
            //    "attention_capacity": {"type": "bool"},
            {"sleep_duration_quality", {{"type", "int"}, {"min", 0}, {"max", 10}}},
            //    "engagement_in_adl": {"type": "bool"},
            {"water_fountains", {{"type", "bool"}}},
            {"recent_freezing_episodes", {{"type", "int"}, {"min", 0}, {"max", 10}}},
            {"heart_rate", {{"type", "int"}, {"min", 40}, {"max", 200}}},
            {"heart_rate_differential", {{"type", "int"}, {"min", -50}, {"max", 50}}},
            {"public_events_frequency", {{"type", "bool"}}},
            {"respiratory_rate", {{"type", "int"}, {"min", 8}, {"max", 50}}},
            {"galvanic_skin_response", {{"type", "int"}, {"min", 0}, {"max", 20}}},
            {"lighting", {{"type", "bool"}}},
            {"noise_pollution", {{"type", "int"}, {"min", 30}, {"max", 120}}},
            {"user_reported_noise_pollution", {{"type", "int"}, {"min", 0}, {"max", 10}}},
            {"air_pollution", {{"type", "int"}, {"min", 0}, {"max", 500}}},
            {"traffic_levels", {{"type", "int"}, {"min", 0}, {"max", 100}}},
            {"lack_of_ventilation", {{"type", "int"}, {"min", 0}, {"max", 10}}},
            //    "daily_steps": {"type": "bool"},
            //    "rehabilitation_school_load": {"type": "bool"},
            //    "heat_waves": {"type": "bool"},
            {"path_slope", {{"type", "bool"}}},
            {"safety_perception", {{"type", "bool"}}},
            //    "fatigue_perception": {"type": "bool"},
            {"rough_path", {{"type", "bool"}}},
            {"public_events_presence", {{"type", "bool"}}},
            // Systolic?
            {"high_blood_pressure", {{"type", "int"}, {"min", 90}, {"max", 200}}},
            // Diastolic?
            {"low_blood_pressure", {{"type", "int"}, {"min", 40}, {"max", 120}}},
            {"social_pressure", {{"type", "bool"}}},
            {"sittings", {{"type", "bool"}}},
            {"self_perception", {{"type", "bool"}}},
            {"restroom_availability", {{"type", "bool"}}},
            {"sweating", {{"type", "int"}, {"min", 0}, {"max", 10}}},
            {"ambient_temperature", {{"type", "float"}, {"min", -30}, {"max", 50}}},
            {"body_temperature", {{"type", "float"}, {"min", 35}, {"max", 42}}},
            {"ambient_humidity", {{"type", "int"}, {"min", 0}, {"max", 100}}},
            {"excessive_urbanization", {{"type", "bool"}}},
            {"green_spaces", {{"type", "bool"}}},
            {"update_udp", {{"type", "bool"}}}};
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
