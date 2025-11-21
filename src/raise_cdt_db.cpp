#include "raise_cdt_db.hpp"
#include "logging.hpp"
#include <mongocxx/client.hpp>
#include <bsoncxx/builder/stream/document.hpp>
#include <cassert>

namespace cdt
{
    raise_cdt_db::raise_cdt_db(coco::mongo_db &db) noexcept : mongo_module(db)
    {
        auto client = get_client();
        auto database = (*client)[db.get_db_name()];
        auto users_collection = database[users_collection_name];
        assert(users_collection);
        if (users_collection.list_indexes().begin() == users_collection.list_indexes().end())
        {
            LOG_DEBUG("Creating indexes for users collection");
            users_collection.create_index(bsoncxx::builder::stream::document{} << "google_id" << 1 << bsoncxx::builder::stream::finalize, mongocxx::options::index{}.unique(true));
        }
    }

    void raise_cdt_db::create_user(std::string_view google_id, std::string_view id)
    {
        bsoncxx::builder::basic::document doc;
        doc.append(bsoncxx::builder::basic::kvp("_id", bsoncxx::oid{id.data()}));
        doc.append(bsoncxx::builder::basic::kvp("google_id", google_id.data()));
        auto client = get_client();
        auto database = (*client)[static_cast<coco::mongo_db &>(db).get_db_name()];
        auto users_collection = database[users_collection_name];
        assert(users_collection);
        if (!users_collection.insert_one(doc.view()))
            throw std::invalid_argument("Failed to insert user with Google ID: " + std::string(google_id));
    }

    std::string raise_cdt_db::get_user(std::string_view google_id)
    {
        auto client = get_client();
        auto database = (*client)[static_cast<coco::mongo_db &>(db).get_db_name()];
        auto users_collection = database[users_collection_name];
        assert(users_collection);
        auto result = users_collection.find_one(bsoncxx::builder::basic::make_document(bsoncxx::builder::basic::kvp("google_id", google_id.data())));
        if (!result)
            throw std::invalid_argument("User with Google ID not found: " + std::string(google_id));
        return result->view()["_id"].get_oid().value.to_string();
    }

    bool raise_cdt_db::user_exists(std::string_view google_id)
    {
        auto client = get_client();
        auto database = (*client)[static_cast<coco::mongo_db &>(db).get_db_name()];
        auto users_collection = database[users_collection_name];
        assert(users_collection);
        return static_cast<bool>(users_collection.find_one(bsoncxx::builder::basic::make_document(bsoncxx::builder::basic::kvp("google_id", google_id.data()))));
    }
} // namespace cdt
