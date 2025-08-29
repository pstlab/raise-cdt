#include "raise_cdt_server.hpp"

namespace cdt
{
    raise_cdt_server::raise_cdt_server(coco::coco_server &srv, raise_cdt &cdt) noexcept : coco::server_module(srv), cdt(cdt) {}
} // namespace cdt
