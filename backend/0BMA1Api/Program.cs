
using _0BMA1Api;
using DotEnv.Core;
using Microsoft.Azure.Cosmos;
using Microsoft.Extensions.Options;
using Microsoft.OpenApi.Models;
using _0BMA1Api.Repository;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.

builder.Services.AddControllers();
// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(c =>
{
    c.SwaggerDoc("v1", new OpenApiInfo { Title = "Fancy TODO API", Version = "v1" });
});



builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAll", policy =>
    {
        policy.AllowAnyOrigin()
              .AllowAnyMethod()
              .AllowAnyHeader();
    });
    options.AddDefaultPolicy(policy =>
        policy.AllowAnyOrigin().AllowAnyHeader().AllowAnyMethod());
    
});



builder.Services.Configure<Microsoft.AspNetCore.Http.Json.JsonOptions>(o =>
{
    o.SerializerOptions.PropertyNamingPolicy = null;
});
new EnvLoader().Load();
// Cosmos config from env
var endpoint = Environment.GetEnvironmentVariable("COSMOS_DB_ENDPOINT");
var key = Environment.GetEnvironmentVariable("COSMOS_DB_KEY");
var database = Environment.GetEnvironmentVariable("COSMOS_DB_DATABASE") ?? "todo";
var container = Environment.GetEnvironmentVariable("COSMOS_DB_CONTAINER") ?? "Todos";

if (!string.IsNullOrWhiteSpace(endpoint) && !string.IsNullOrWhiteSpace(key))
{
    builder.Services.AddSingleton<ITodoRepository>(sp =>
    {

         var client = new CosmosClient(endpoint, key);
       // var connection = String.Format("AccountEndpoint={0};AccountKey={1}", endpoint, key);
        //var client = new CosmosClient(connection);
        //"AccountEndpoint=https://bma1project.documents.azure.com:443/;AccountKey=
        //JVxoERmH913PyK9EKc7qEYJb6Pdb88YTjBzW1isgu4thdIniLQ7BqoQ4pfaa0dBWk5DMBgSX2OQdACDbAVTG2g==;");
        //JVxoERm913PyK9EKc7qEYJb6Pdb88YTjBzW1isgu4thdIniLQ7BqoQ4pfaa0dBWk5DMBgSX2OQdACDbAVTG2g==;
        var db = client.GetDatabase(database);
        var cont = db.GetContainer(container);
        return new CosmosTodoRepository(cont);
    });
}

//builder.Services.AddValidatorsFromAssemblyContaining<TodoValidator>();

var port = Environment.GetEnvironmentVariable("PORT");
if (!string.IsNullOrEmpty(port))
{
    builder.WebHost.UseUrls($"http://*:{port}");
}
else
{

#if !DEBUG
    builder.WebHost.UseUrls("http://*:80");
#endif
}
var app = builder.Build();

app.MapGet("/", () => "Todo API is running. Visit /swagger for docs.");

// Configure the HTTP request pipeline.
//Important: These lines must be outside any if (env.IsDevelopment()) block. Otherwise, Swagger won’t run in production — and your Docker container uses production mode by default.
//if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

//app.UseHttpsRedirection();
app.UseRouting();
//app.UseAuthorization();

app.MapControllers();


//app.UseAuthorization(); // if using [Authorize]
//app.MapControllers();


app.UseCors("AllowAll");
app.Run();
