using ToworkMVC.Models;

namespace ToworkMVC.Services;

public class TasksService : ITasksService
{
    // TODO: Use a DbContex instead!
    private List<ToworkTask> _tasks = [];

    public List<ToworkTask> GetTasks()
    {
        return _tasks;
    }

    public ToworkTask CreateTask(ToworkTask task)
    {
        task.Id = _tasks.Count;
        _tasks.Add(task);
        return task;
    }

    public bool DeleteTask(int id)
    {
        if (id < _tasks.Count)
        {
            _tasks.RemoveAt(id);
            return true;
        }
        return false;
    }

    public ToworkTask? UpdateTask(int id, ToworkTask task)
    {
        ToworkTask? t = _tasks.FirstOrDefault(t => t.Id == id);
        if (t is null)
            return null;

        t.Complete = task.Complete;
        t.Label = task.Label;
        return t;
    }
}
