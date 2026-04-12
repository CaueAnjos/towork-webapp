namespace ToworkMVC.Models;

public class ToworkTask
{
    public int Id { get; set; }
    public string Label { get; set; } = string.Empty;
    public bool Complete { get; set; } = false;
}
