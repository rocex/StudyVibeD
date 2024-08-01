module employee;

import vibe.vibe;

@path("/employee/")
interface IEmployee
{
    @path("testString")
    @method(HTTPMethod.GET)
    string getTest1();

    @path("testJson")
    @method(HTTPMethod.GET)
    Json testJson();
}

class EmployeeImpl : IEmployee
{
    @safe:
    override string getTest1()
    {
        return "employee index";
    }

    override Json testJson()
    {
        return serializeToJson([
        "foo": "42",
        "bar": "13",
        "flag": "employee test"
        ]);
    }
}

@path("/api/")
interface APIRoot
{
    @path("api2") @trusted
    string get2();
}

class API : APIRoot
{
    override string get2() @trusted
    {
        return "Hello, World";
    }
}
