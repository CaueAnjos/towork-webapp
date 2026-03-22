using ToworkMVC.Models;

namespace ToworkMVC.Services;

public class TasksService(TasksContext tasksContext) : ITasksService
{
    private TasksContext _context = tasksContext;

    public List<ToworkTask> GetTasks()
    {
        return _context.Tasks.OrderBy((e) => e.Id).ToList();
    }

    public async Task<ToworkTask> CreateTask(ToworkTask task)
    {
        await _context.Tasks.AddAsync(task);
        await _context.SaveChangesAsync();
        return task;
    }

    public async Task<bool> DeleteTask(int id)
    {
        ToworkTask? taskToDelete = await _context.Tasks.FindAsync(id);
        if (taskToDelete is null)
            return false;

        _context.Tasks.Remove(taskToDelete);
        await _context.SaveChangesAsync();
        return true;
    }

    public async Task<ToworkTask?> UpdateTask(int id, ToworkTask task)
    {
        ToworkTask? t = await _context.Tasks.FindAsync(id);
        if (t is null)
            return null;

        t.Complete = task.Complete;
        t.Label = task.Label;
        await _context.SaveChangesAsync();
        return t;
    }
}
