using Microsoft.EntityFrameworkCore;

namespace ToworkMVC.Models;

public class TasksContext : DbContext
{
#nullable disable
    public TasksContext(DbContextOptions<TasksContext> options)
        : base(options) { }

    public DbSet<ToworkTask> Tasks { get; set; }
}
