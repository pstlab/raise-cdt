#pragma once

#include "coco_server.hpp"
#include "raise_cdt.hpp"

namespace cdt
{
  class raise_cdt_server : public coco::server_module
  {
  public:
    raise_cdt_server(coco::coco_server &srv, raise_cdt &cdt) noexcept;

    std::unique_ptr<network::response> get_user(const network::request &req);
    std::unique_ptr<network::response> new_user(const network::request &req);

  private:
    raise_cdt &cdt;
  };
} // namespace cdt
