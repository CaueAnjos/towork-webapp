using Microsoft.AspNetCore.Mvc;
using ToworkMVC.Models;
using ToworkMVC.Services;

namespace ToworkMVC.Controllers;

[ApiController]
[Route("tasks")]
public class TasksController(ITasksService tasksService) : Controller
{
    private ITasksService _tasks = tasksService;

    [HttpGet]
    public IActionResult GetTasks()
    {
        return Json(_tasks.GetTasks());
    }

    [HttpPut("{id}")]
    public IActionResult UpdateTask(int id, ToworkTask task)
    {
        // TODO: return a response Task
        return Ok(_tasks.UpdateTask(id, task));
    }

    [HttpDelete("{id}")]
    public IActionResult DeleteTask(int id)
    {
        _tasks.DeleteTask(id);
        return NoContent();
    }

    [HttpPost]
    public IActionResult CreateTask(ToworkTask task)
    {
        var response = _tasks.CreateTask(task);
        return CreatedAtAction(nameof(CreatedAtAction), response);
    }
}
