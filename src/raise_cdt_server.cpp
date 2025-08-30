#include "raise_cdt_server.hpp"

namespace cdt
{
    raise_cdt_server::raise_cdt_server(coco::coco_server &srv, raise_cdt &cdt) noexcept : server_module(srv), cdt(cdt)
    {
        srv.add_route(network::Get, "^/users/.*$", std::bind(&raise_cdt_server::get_user, this, network::placeholders::request));
        srv.add_route(network::Post, "^/users$", std::bind(&raise_cdt_server::create_user, this, network::placeholders::request));

        // Define OpenAPI paths for user management
        add_path("/users/{keycloak_id}", {"get",
                                          {{"summary", "Get User"},
                                           {"description", "Retrieves a user by their Keycloak ID."},
                                           {"parameters", {{{"name", "keycloak_id"}, {"in", "path"}, {"required", true}, {"schema", {{"type", "string"}, {"format", "uuid"}}}, {"description", "The Keycloak ID of the user to retrieve."}}}},
                                           {"responses",
                                            {{"200",
                                              {{"description", "User retrieved successfully."}, {"content", {{"application/json", {{"schema", {{"type", {"$ref", "#/components/schemas/item"}}}}}}}}}},
                                             {"404",
                                              {{"description", "User not found."}}}}}}});
        add_path("/users", {"post",
                            {{"summary", "Create User"},
                             {"description", "Creates a new user with the specified Keycloak ID."},
                             {"requestBody",
                              {{"required", true},
                               {"content", {{"application/json", {{"schema", {{"type", "object"}, {"properties", {{"keycloak_id", {{"type", "string"}, {"format", "uuid"}, {"description", "The Keycloak ID for the new user."}}}}}, {"required", {"keycloak_id"}}}}}}}}}},
                             {"responses",
                              {{"201",
                                {{"description", "User created successfully."}}},
                               {"409",
                                {{"description", "User already exists."}}},
                               {"400",
                                {{"description", "Invalid request."}}}}}}});
    }

    std::unique_ptr<network::response> raise_cdt_server::get_user(const network::request &req)
    {
        try
        {
            auto &user = cdt.get_user(req.get_target().substr(7));
            auto j_user = user.to_json();
            j_user["id"] = user.get_id();
            return std::make_unique<network::json_response>(std::move(j_user));
        }
        catch (const std::exception &)
        {
            return std::make_unique<network::json_response>(json::json({{"message", "User not found"}}), network::status_code::not_found);
        }
    }

    std::unique_ptr<network::response> raise_cdt_server::create_user(const network::request &req)
    {
        auto &body = static_cast<const network::json_request &>(req).get_body();
        if (!body.is_object() || !body.contains("keycloak_id") || !body["keycloak_id"].is_string())
            return std::make_unique<network::json_response>(json::json({{"message", "Invalid request"}}), network::status_code::bad_request);

        std::string keycloak_id = body["keycloak_id"];
        try
        {
            cdt.create_user(keycloak_id);
            return std::make_unique<network::response>(network::status_code::created);
        }
        catch (const std::exception &e)
        {
            return std::make_unique<network::json_response>(json::json({{"message", e.what()}}), network::status_code::conflict);
        }
    }
} // namespace cdt
