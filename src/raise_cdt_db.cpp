#include "raise_cdt_db.hpp"
#include "logging.hpp"
#include <bsoncxx/builder/stream/document.hpp>
#include <cassert>

namespace cdt
{
    raise_cdt_db::raise_cdt_db(coco::mongo_db &db, std::string_view postgresql_uri) noexcept : mongo_module(db), users_collection(get_db()["users"]), pg_conn(postgresql_uri.data())
    {
        assert(users_collection);
        if (users_collection.list_indexes().begin() == users_collection.list_indexes().end())
        {
            LOG_DEBUG("Creating indexes for users collection");
            users_collection.create_index(bsoncxx::builder::stream::document{} << "keycloak_id" << 1 << bsoncxx::builder::stream::finalize, mongocxx::options::index{}.unique(true));
        }
        assert(pg_conn.is_open());
        LOG_DEBUG("Connected to Urban Data Platform PostgreSQL database");
    }

    void raise_cdt_db::create_user(std::string_view keycloak_id, std::string_view id)
    {
        bsoncxx::builder::basic::document doc;
        doc.append(bsoncxx::builder::basic::kvp("_id", bsoncxx::oid{id.data()}));
        doc.append(bsoncxx::builder::basic::kvp("keycloak_id", keycloak_id.data()));
        if (!users_collection.insert_one(doc.view()))
            throw std::invalid_argument("Failed to insert user with Keycloak ID: " + std::string(keycloak_id));
    }

    std::string raise_cdt_db::get_user(std::string_view keycloak_id)
    {
        auto result = users_collection.find_one(bsoncxx::builder::basic::make_document(bsoncxx::builder::basic::kvp("keycloak_id", keycloak_id.data())));
        if (!result)
            throw std::invalid_argument("User with Keycloak ID not found: " + std::string(keycloak_id));
        return result->view()["_id"].get_oid().value.to_string();
    }

    bool raise_cdt_db::user_exists(std::string_view keycloak_id) { return static_cast<bool>(users_collection.find_one(bsoncxx::builder::basic::make_document(bsoncxx::builder::basic::kvp("keycloak_id", keycloak_id.data())))); }

    std::vector<raise_user> raise_cdt_db::get_users() noexcept
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

    json::json raise_cdt_db::get_urban_data_platform_data(std::string_view keycloak_id)
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
