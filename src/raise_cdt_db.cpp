#include "raise_cdt_db.hpp"

namespace cdt
{
    raise_cdt_db::raise_cdt_db(coco::mongo_db &db) noexcept : coco::db_module(db) {}
} // namespace cdt
