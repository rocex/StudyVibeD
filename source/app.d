import vibe.vibe;

import std.algorithm;
import std.array;
import std.stdio;

void main()
{
    auto settings = new HTTPServerSettings;
    settings.port = 8080;
    settings.bindAddresses = ["::1", "127.0.0.1"];

    auto listener = listenHTTP(settings, getRouter());

    scope (exit)
    {
        listener.stopListening();
    }

    logInfo("Please open http://127.0.0.1:" ~ to!string(settings.port) ~ "/ in your browser.");

    runApplication();
}

void hello(HTTPServerRequest req, HTTPServerResponse res)
{
    res.writeBody("Hello, World!");
}

auto getRouter()
{
    auto router = new URLRouter();

    router.get("/", staticTemplate!"index.dt");
    router.get("*", serveStaticFiles("public/"));

    router.get("/hello", &hello);
    router.get("/hello2", staticTemplate!"hello.dt");
    router.get("/sticky-footer-navbar", staticTemplate!"sticky-footer-navbar.html");
    router.get("/noboot", staticTemplate!"noboot.home.dt");

    //
    const data = q{
        PUT /public/devices/commandList
        PUT /public/devices/logicStateList
        OPTIONS /public/devices/commandList
        OPTIONS /public/devices/logicStateList
        PUT /public/mnemoschema
        PUT /public/static
        PUT /public/dynamic
        PUT /public/info
        PUT /public/info-network
        PUT /public/events
        PUT /public/eventList
        PUT /public/availBatteryModels
        OPTIONS /public/availBatteryModels
        OPTIONS /public/dynamic
        OPTIONS /public/eventList
        OPTIONS /public/events
        OPTIONS /public/info
        OPTIONS /public/info-network
        OPTIONS /public/mnemoschema
        OPTIONS /public/static
        PUT /settings/admin/getinfo
        PUT /settings/admin/setconf
        PUT /settings/admin/checksetaccess
        OPTIONS /settings/admin/checksetaccess
        OPTIONS /settings/admin/getinfo
        OPTIONS /settings/admin/setconf
    }.splitLines
        .map!(a => a.strip.split)
        .filter!(a => a.length)
        .array;

    foreach (a; data)
    {
        router.match(a[0].to!HTTPMethod, a[1], (q, s) { s.writeBody("ok"); });
    }

    foreach (r; router.getAllRoutes())
        stderr.writefln!"%s %s"(r.method, r.pattern);

    router.rebuild;

    return router;
}
