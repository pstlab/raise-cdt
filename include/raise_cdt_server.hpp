#pragma once

#include "coco_server.hpp"
#include "raise_cdt.hpp"

namespace cdt
{
  class cdt_server : public coco::coco_server
  {
  public:
    restart_server(coco::coco_server &srv, restart &rst) noexcept;

    std::unique_ptr<network::response> get_user(const network::request &req);
    std::unique_ptr<network::response> new_user(const network::request &req);
  };
} // namespace cdt
