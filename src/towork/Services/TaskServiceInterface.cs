using ToworkMVC.Models;

namespace ToworkMVC.Services;

public interface ITasksService
{
    public List<ToworkTask> GetTasks();
    public Task<ToworkTask?> GetTask(int id);
    public Task<ToworkTask> CreateTask(ToworkTask task);
    public Task<bool> DeleteTask(int id);
    public Task<ToworkTask?> UpdateTask(int id, ToworkTask task);
}
