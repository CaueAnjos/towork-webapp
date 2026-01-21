using Microsoft.AspNetCore.Mvc;

namespace ToworkMVC.Controllers;

[Route("api")]
public class ApiController : Controller
{
    [HttpGet("hello/{id}/")]
    public IActionResult Hello(int id, string name)
    {
        return Json(new { message = "Hello World from MVC!", name = name, id = id });
    }
}
