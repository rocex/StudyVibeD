import vibe.vibe;

import std.algorithm;
import std.array;
import std.stdio;
import std.traits;
import employee;

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

    logInfo("\nPlease open http://127.0.0.1:%d/ in your browser.", settings.port);

    runApplication();
}

void hello(HTTPServerRequest req, HTTPServerResponse res)
{
    res.writeBody("Hello, World!");
}

void registerInterface(URLRouter router, string clazz)
{
    auto instance = Object.factory(clazz);

    if (instance is null)
    {
        return;
    }

    // logInfo("[%s] type is [%s]", clazz, to!string((typeof(instance))));
    // logInfo(cast(Object)(instance));

    static if (is(typeof(instance) == class))
    {
        router.registerWebInterface(instance);
    }
    else static if (is(typeof(instance) == interface))
    {
        router.registerRestInterface(instance);
    }
}

auto getRouter()
{
    auto router = new URLRouter();

    router.get("/", staticTemplate!"index.dt");
    router.get("*", serveStaticFiles("public/"));

    router.get("/hello", &hello);
    router.get("/hello2", staticTemplate!"hello.dt");
    router.get("/sticky-footer-navbar", staticTemplate!"sticky-footer-navbar.html");
    router.get("/noboot", staticTemplate!"noboot/home.dt");
    router.get("/race-bar-country", staticTemplate!"race-bar/race-bar-country.html");
    router.get("/race-bar-country2", staticTemplate!"race-bar/race-bar-country2.html");

    logInfo("EmployeeImpl %s", EmployeeImpl.classinfo.name);

    auto employee = cast(EmployeeImpl) Object.factory("employee.EmployeeImpl");

    router.registerWebInterface(employee);

    logInfo("IEmployee is class? %s", is(IEmployee == class));
    logInfo("EmployeeImpl is class? %s", is(typeof(employee) == class));

    logInfo("APIRoot is interface? %s", is(APIRoot == interface));
    logInfo("API is interface? %s", is(API == interface));

    router.registerRestInterface(employee, "api");
    router.registerRestInterface(new API(), "api");

    registerInterface(router, "employee.IEmployee");

    // registerOthers(router);

    //router.rebuild();

    foreach (r; router.getAllRoutes())
        logInfo("%s %s", r.method, r.pattern);
    return router;
}

void registerOthers(URLRouter router)
{
    const data = q{
        PUT /public/devices/commandList
        PUT /public/devices/logicStateList
        OPTIONS /public/devices/commandList
        OPTIONS /public/devices/logicStateList
        PUT /public/eventList
        PUT /public/availBatteryModels
        OPTIONS /public/availBatteryModels
        OPTIONS /public/static
        PUT /settings/admin/getinfo
        PUT /settings/admin/checksetaccess
        OPTIONS /settings/admin/checksetaccess
    }.splitLines
        .map!(a => a.strip.split)
        .filter!(a => a.length)
        .array;
    foreach (a; data)
    {
        router.match(a[0].to!HTTPMethod, a[1], (q, s) { s.writeBody("ok"); });
    }
}
