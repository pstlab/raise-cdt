#include "raise_cdt_db.hpp"
#include "logging.hpp"
#include <bsoncxx/builder/stream/document.hpp>
#include <cassert>

namespace cdt
{
    raise_cdt_db::raise_cdt_db(coco::mongo_db &db) noexcept : mongo_module(db), users_collection(get_db()["users"]), pg_conn(POSTGRES_URI(POSTGRES_ACCOUNT, POSTGRES_HOST, POSTGRES_PORT))
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
        pqxx::result r = txn.exec("SELECT id, static_props FROM users");
        for (const auto &row : r)
            users.emplace_back(raise_user{row[0].c_str(), json::load(row[1].c_str())});
        return users;
    }

    json::json raise_cdt_db::get_urban_data_platform_data(std::string_view keycloak_id)
    {
        pqxx::work txn{pg_conn};
        pqxx::result r = txn.exec_params("SELECT udp_data FROM users WHERE keycloak_id = $1", keycloak_id.data());
        if (r.empty())
            throw std::invalid_argument("User with Keycloak ID not found: " + std::string(keycloak_id));
        return json::load(r[0][0].c_str());
    }
} // namespace cdt
