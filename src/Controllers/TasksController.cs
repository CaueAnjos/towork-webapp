using Microsoft.AspNetCore.Mvc;
using ToworkMVC.DTO;
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
    public IActionResult UpdateTask(int id, UpdateTaskResquest request)
    {
        // TODO: return a response Task
        var response = _tasks.UpdateTask(id, (ToworkTask)request);
        if (response is null)
            return NotFound();

        return Ok((DefaultTaskResponse)response);
    }

    [HttpDelete("{id}")]
    public IActionResult DeleteTask(int id)
    {
        _tasks.DeleteTask(id);
        return NoContent();
    }

    [HttpPost]
    public IActionResult CreateTask(CreateTaskRequest request)
    {
        var response = _tasks.CreateTask((ToworkTask)request);
        if (response is null)
            return BadRequest();

        return CreatedAtAction(nameof(CreatedAtAction), (DefaultTaskResponse)response);
    }
}
