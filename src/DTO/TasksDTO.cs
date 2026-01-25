using ToworkMVC.Models;

namespace ToworkMVC.DTO;

public record CreateTaskRequest(string Label)
{
    public static explicit operator ToworkTask(CreateTaskRequest request)
    {
        return new ToworkTask { Complete = false, Label = request.Label };
    }
}

public record UpdateTaskResquest(string Label, bool Complete)
{
    public static explicit operator ToworkTask(UpdateTaskResquest request)
    {
        return new ToworkTask { Complete = request.Complete, Label = request.Label };
    }
}

public record DefaultTaskResponse(int Id, string Label, bool Complete)
{
    public static explicit operator DefaultTaskResponse(ToworkTask task)
    {
        return new DefaultTaskResponse(task.Id, task.Label, task.Complete);
    }
}
