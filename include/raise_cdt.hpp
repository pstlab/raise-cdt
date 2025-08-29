#pragma once

#include "coco_module.hpp"

namespace cdt
{
  class raise_cdt : public coco::coco_module
  {
  public:
    raise_cdt(coco::coco &cc) noexcept;
  };
} // namespace cdt
