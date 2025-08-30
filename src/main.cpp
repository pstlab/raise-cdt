#include "raise_cdt.hpp"
#include "coco.hpp"
#include "mongo_db.hpp"
#include "raise_cdt_server.hpp"
#include <mongocxx/instance.hpp>
#include <thread>

int main()
{
    mongocxx::instance inst{}; // This should be done only once.
    coco::mongo_db db;
    coco::coco cc(db);
    auto &cdt = cc.add_module<cdt::raise_cdt>(cc);
    cc.init();

    coco::coco_server srv(cc);
    srv.add_module<cdt::raise_cdt_server>(srv, cdt);
    auto srv_ft = std::async(std::launch::async, [&srv]
                             { srv.start(); });

    return 0;
}
