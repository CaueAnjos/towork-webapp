using Microsoft.AspNetCore.Mvc;
using ToworkMVC.DTO;
using ToworkMVC.Models;
using ToworkMVC.Services;

namespace ToworkMVC.Controllers;

[ApiController]
[Route("api/[controller]")]
public class TasksController(ITasksService tasksService) : Controller
{
    private ITasksService _tasks = tasksService;

    [HttpGet]
    public IActionResult GetTasks()
    {
        return Json(_tasks.GetTasks());
    }

    [HttpPut("{id}")]
    public async Task<IActionResult> UpdateTask(int id, UpdateTaskResquest request)
    {
        // TODO: return a response Task
        var response = await _tasks.UpdateTask(id, (ToworkTask)request);
        if (response is null)
            return NotFound();

        return Ok((DefaultTaskResponse)response);
    }

    [HttpDelete("{id}")]
    public async Task<IActionResult> DeleteTask(int id)
    {
        if (!await _tasks.DeleteTask(id))
            return NotFound();

        return NoContent();
    }

    [HttpPost]
    public async Task<IActionResult> CreateTask(CreateTaskRequest request)
    {
        var response = await _tasks.CreateTask((ToworkTask)request);
        if (response is null)
            return BadRequest();

        return CreatedAtAction(nameof(CreatedAtAction), (DefaultTaskResponse)response);
    }
}
