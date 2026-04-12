using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.FileProviders;
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

var uiRoot = GetUiRootPath(builder.Environment);
var uiFileProvider = new PhysicalFileProvider(uiRoot);

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

app.UseDefaultFiles(new DefaultFilesOptions { FileProvider = uiFileProvider });
app.UseStaticFiles(new StaticFileOptions { FileProvider = uiFileProvider });

app.MapControllers();

app.MapFallback(async context =>
{
    context.Response.ContentType = "text/html";
    await context.Response.SendFileAsync(Path.Combine(uiRoot, "index.html"));
});

app.Run();

static string GetUiRootPath(IWebHostEnvironment environment)
{
    var devUiRoot = Environment.GetEnvironmentVariable("TOWORK_UI_ROOT");
    if (!string.IsNullOrWhiteSpace(devUiRoot) && Directory.Exists(devUiRoot))
        return devUiRoot;

    if (!string.IsNullOrWhiteSpace(environment.WebRootPath) && Directory.Exists(environment.WebRootPath))
        return environment.WebRootPath;

    return Path.Combine(environment.ContentRootPath, "wwwroot");
}
