#pragma once

#include "mongo_db.hpp"

namespace cdt
{
  class raise_cdt_db : public coco::db_module
  {
  public:
    raise_cdt_db(coco::mongo_db &db) noexcept;
  };
} // namespace cdt
