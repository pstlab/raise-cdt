#include "raise_cdt_db.hpp"
#include "logging.hpp"
#include <bsoncxx/builder/stream/document.hpp>
#include <cassert>

namespace cdt
{
    raise_cdt_db::raise_cdt_db(coco::mongo_db &db) noexcept : mongo_module(db), users_collection(get_db()["users"])
    {
        assert(users_collection);
        if (users_collection.list_indexes().begin() == users_collection.list_indexes().end())
        {
            LOG_DEBUG("Creating indexes for users collection");
            users_collection.create_index(bsoncxx::builder::stream::document{} << "keycloak_id" << 1 << bsoncxx::builder::stream::finalize, mongocxx::options::index{}.unique(true));
        }
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
} // namespace cdt
