using Microsoft.EntityFrameworkCore;
using Scalar.AspNetCore;
using ToworkMVC.Models;
using ToworkMVC.Services;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddControllersWithViews();
builder.Services.AddOpenApi();
builder.Services.AddTransient<ITasksService, TasksService>();
builder.Services.AddDbContext<TasksContext>(options =>
{
    options.UseNpgsql(builder.Configuration.GetConnectionString("TasksContext"));
});
builder.Services.AddCors(options =>
{
    options.AddPolicy(
        name: "allowed",
        policy =>
        {
            policy
                .WithOrigins("http://localhost:4173", "http://localhost:5173")
                .AllowAnyHeader()
                .AllowAnyMethod();
        }
    );
});

var app = builder.Build();
app.UseCors("allowed");

// Configure the HTTP request pipeline.
if (!app.Environment.IsDevelopment())
{
    app.UseExceptionHandler("/Home/Error");
    // The default HSTS value is 30 days. You may want to change this for production scenarios, see https://aka.ms/aspnetcore-hsts.
    app.UseHsts();
}
else
{
    app.MapOpenApi();
    app.MapScalarApiReference();
}

app.UseHttpsRedirection();
app.UseRouting();

app.UseAuthorization();

app.MapStaticAssets();

app.MapControllerRoute(name: "default", pattern: "{controller=Home}/{action=Index}/{id?}")
    .WithStaticAssets();

app.Run();
