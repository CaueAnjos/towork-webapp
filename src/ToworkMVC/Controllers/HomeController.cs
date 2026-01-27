using System.Diagnostics;
using Microsoft.AspNetCore.Mvc;
using ToworkMVC.Models;

namespace ToworkMVC.Controllers;

public class HomeController : Controller
{
    public IActionResult Index()
    {
        return View();
    }
}
