var builder = WebApplication.CreateBuilder(args);
builder.Services.AddControllers();
var app = builder.Build();

app.MapControllers();
app.MapGet("/", () => "Hello from Weather API!");

app.Run();