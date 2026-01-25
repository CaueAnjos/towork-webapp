using Microsoft.AspNetCore.Mvc;

namespace ToworkMVC.Controllers;

[ApiController]
[Route("tasks")]
public class TasksController : Controller
{
    [HttpGet("{id}")]
    public IActionResult GetTasks()
    {
        // TODO: implement!
        return Json(new { });
    }

    [HttpPut("{id}")]
    public IActionResult UpdateTask(int id)
    {
        // TODO: implement!
        return Ok();
    }

    [HttpDelete("{id}")]
    public IActionResult DeleteTask(int id)
    {
        // TODO: implement!
        return NoContent();
    }

    [HttpPost]
    public IActionResult CreateTask()
    {
        // TODO: implement!
        return CreatedAtAction(nameof(CreatedAtAction), new { });
    }
}
