using ToworkMVC.Models;

namespace ToworkMVC.Services;

public interface ITasksService
{
    public List<ToworkTask> GetTasks();
    public ToworkTask CreateTask(ToworkTask task);
    public void DeleteTask(int id);
    public ToworkTask? UpdateTask(int id, ToworkTask task);
}
