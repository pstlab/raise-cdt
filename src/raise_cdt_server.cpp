#include "raise_cdt_server.hpp"
#ifdef BUILD_AUTH
#include "coco_auth.hpp"
#endif
#include "logging.hpp"

namespace cdt
{
    raise_cdt_server::raise_cdt_server(coco::coco_server &srv, raise_cdt &cdt) noexcept : server_module(srv), cdt(cdt)
    {
        srv.add_route(network::Get, "^/raise-users/.*$", std::bind(&raise_cdt_server::get_user, this, network::placeholders::request));
        srv.add_route(network::Post, "^/raise-users$", std::bind(&raise_cdt_server::create_user, this, network::placeholders::request));

        // Define OpenAPI paths for user management
        add_path("/raise-users/{google_id}", {"get",
                                              {{"summary", "Get User"},
                                               {"description", "Retrieves a user by their Google ID."},
                                               {"parameters", {{{"name", "google_id"}, {"in", "path"}, {"required", true}, {"schema", {{"type", "string"}}}, {"description", "The Google ID of the user to retrieve."}}}},
#ifdef BUILD_AUTH
                                               {"security", std::vector<json::json>{{"bearerAuth", std::vector<json::json>{}}}},
#endif
                                               {"responses",
                                                {{"200",
                                                  {{"description", "User retrieved successfully."}, {"content", {{"application/json", {{"schema", {{"$ref", "#/components/schemas/item"}}}}}}}}},
#ifdef BUILD_AUTH
                                                 {"401", {{"$ref", "#/components/responses/UnauthorizedError"}}},
#endif
                                                 {"404",
                                                  {{"description", "User not found."}}}}}}});
        add_path("/raise-users", {"post",
                                  {{"summary", "Create User"},
                                   {"description", "Creates a new user with the specified Google ID."},
                                   {"requestBody",
                                    {{"required", true},
                                     {"content", {{"application/json", {{"schema", {{"type", "object"}, {"properties", {{"google_id", {{"type", "string"}, {"description", "The Google ID for the new user."}}}}}, {"required", {"google_id"}}}}}}}}}},
#ifdef BUILD_AUTH
                                   {"security", std::vector<json::json>{{"bearerAuth", std::vector<json::json>{}}}},
#endif
                                   {"responses",
                                    {{"201",
                                      {{"description", "User created successfully."}, {"content", {{"text/plain", {{"schema", {{"type", "string"}, {"pattern", "^[a-fA-F0-9]{24}$"}, {"description", "The ID of the newly created item."}}}}}}}}},
                                     {"400",
                                      {{"description", "Invalid request."}}},
#ifdef BUILD_AUTH
                                     {"401", {{"$ref", "#/components/responses/UnauthorizedError"}}},
#endif
                                     {"409",
                                      {{"description", "User already exists."}}}}}}});

        add_path("/raise-users/{google_id}", {"patch",
                                              {{"summary", "Update User"},
                                               {"description", "Updates an existing user with the specified Google ID."},
                                               {"parameters", {{{"name", "google_id"}, {"in", "path"}, {"required", true}, {"schema", {{"type", "string"}}}, {"description", "The Google ID of the user to update."}}}},
                                               {"requestBody",
                                                {{"required", true},
                                                 {"content", {{"application/json", {{"schema", {{"type", "object"}, {"properties", {{"data", {{"type", "object"}, {"description", "The data to update for the user."}}}}}, {"required", {"data"}}}}}}}}}},
#ifdef BUILD_AUTH
                                               {"security", std::vector<json::json>{{"bearerAuth", std::vector<json::json>{}}}},
#endif
                                               {"responses",
                                                {{"200",
                                                  {{"description", "User updated successfully."}}},
                                                 {"400",
                                                  {{"description", "Invalid request."}}},
#ifdef BUILD_AUTH
                                                 {"401", {{"$ref", "#/components/responses/UnauthorizedError"}}},
#endif
                                                 {"404",
                                                  {{"description", "User not found."}}}}}}});

        add_path("/raise-users/{google_id}/data", {"post",
                                                   {{"summary", "Add User Data"},
                                                    {"description", "Adds data to an existing user with the specified Google ID."},
                                                    {"parameters", {{{"name", "google_id"}, {"in", "path"}, {"required", true}, {"schema", {{"type", "string"}}}, {"description", "The Google ID of the user to add data to."}}}},
                                                    {"requestBody",
                                                     {{"required", true},
                                                      {"content", {{"application/json", {{"schema", {{"type", "object"}, {"properties", {{"data", {{"type", "object"}, {"description", "The data to add for the user."}}}}}, {"required", {"data"}}}}}}}}}},
#ifdef BUILD_AUTH
                                                    {"security", std::vector<json::json>{{"bearerAuth", std::vector<json::json>{}}}},
#endif
                                                    {"responses",
                                                     {{"200",
                                                       {{"description", "User data added successfully."}}},
                                                      {"400",
                                                       {{"description", "Invalid request."}}}}}}});

#ifdef BUILD_AUTH
        auto &auth = static_cast<coco::auth_middleware &>(srv.get_middleware<coco::auth_middleware>());
        auth.add_authorized_path(network::Get, "^/raise-users/.*$", {0, 1});
        auth.add_authorized_path(network::Post, "^/raise-users$", {0});
#endif
    }

    std::unique_ptr<network::response> raise_cdt_server::get_user(const network::request &req)
    {
        try
        {
            auto &user = cdt.get_user(req.get_target().substr(13)); // 13 is the length of "/raise-users/"
            auto j_user = user.to_json();
            j_user["id"] = user.get_id();
            return std::make_unique<network::json_response>(std::move(j_user));
        }
        catch (const std::exception &ex)
        {
            return std::make_unique<network::json_response>(json::json({{"message", "User not found"}}), network::status_code::not_found);
        }
    }

    std::unique_ptr<network::response> raise_cdt_server::create_user(const network::request &req)
    {
        auto &body = static_cast<const network::json_request &>(req).get_body();
        if (!body.is_object() || !body.contains("google_id") || !body["google_id"].is_string())
            return std::make_unique<network::json_response>(json::json({{"message", "Invalid request"}}), network::status_code::bad_request);

        std::string google_id = body["google_id"];
        try
        {
            auto &usr = cdt.create_user(google_id);
            return std::make_unique<network::string_response>(std::string(usr.get_id()), network::status_code::created);
        }
        catch (const std::exception &ex)
        {
            return std::make_unique<network::json_response>(json::json({{"message", ex.what()}}), network::status_code::conflict);
        }
    }

    std::unique_ptr<network::response> raise_cdt_server::update_user(const network::request &req)
    {
        auto &body = static_cast<const network::json_request &>(req).get_body();
        if (!body.is_object())
            return std::make_unique<network::json_response>(json::json({{"message", "Invalid request"}}), network::status_code::bad_request);

        std::string google_id = req.get_target().substr(13); // 13 is the length of "/raise-users/"
        try
        {
            cdt.update_user(google_id, json::json(body));
            return std::make_unique<network::json_response>(json::json({{"message", "User updated successfully"}}));
        }
        catch (const std::exception &ex)
        {
            return std::make_unique<network::json_response>(json::json({{"message", ex.what()}}), network::status_code::not_found);
        }
    }

    std::unique_ptr<network::response> raise_cdt_server::add_user_value(const network::request &req)
    {
        auto &body = static_cast<const network::json_request &>(req).get_body();
        if (!body.is_object())
            return std::make_unique<network::json_response>(json::json({{"message", "Invalid request"}}), network::status_code::bad_request);

        std::string google_id = req.get_target().substr(13, req.get_target().find("/data") - 13); // Extract Google ID from the path
        try
        {
            cdt.add_user_value(google_id, json::json(body));
            return std::make_unique<network::json_response>(json::json({{"message", "User data added successfully"}}));
        }
        catch (const std::exception &ex)
        {
            return std::make_unique<network::json_response>(json::json({{"message", ex.what()}}), network::status_code::not_found);
        }
    }
} // namespace cdt
