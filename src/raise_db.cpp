#include "raise_db.hpp"
#include "logging.hpp"
#include <cassert>

namespace cdt
{
    raise_db::raise_db(coco::coco_db &db, std::string_view postgresql_uri) noexcept : db_module(db), pg_conn(postgresql_uri.data())
    {
        assert(pg_conn.is_open());
        LOG_DEBUG("Connected to Urban Data Platform PostgreSQL database");
    }

    std::vector<raise_user> raise_db::get_users() noexcept
    {
        std::vector<raise_user> users;
        pqxx::work txn{pg_conn};
        pqxx::result r = txn.exec("SELECT id, baseline_nutrition, baseline_fall FROM users");
        for (const auto &row : r)
        {
            raise_user usr;
            usr.id = row["id"].c_str();
            usr.static_props = {{"baseline_nutrition", row["baseline_nutrition"].as<int>()}, {"baseline_fall", row["baseline_fall"].as<int>()}};
            users.push_back(std::move(usr));
        }
        return users;
    }

    json::json raise_db::get_urban_data_platform_data(std::string_view keycloak_id)
    {
        pqxx::work txn{pg_conn};
        pqxx::result r = txn.exec_params("SELECT lighting, noise_pollution FROM users WHERE id = $1", keycloak_id.data());
        if (r.empty())
            throw std::invalid_argument("User with Keycloak ID not found: " + std::string(keycloak_id));
        json::json udp_data;
        udp_data["lighting"] = r[0]["lighting"].as<int>();
        udp_data["noise_pollution"] = r[0]["noise_pollution"].as<int>();
        return udp_data;
    }
} // namespace cdt
