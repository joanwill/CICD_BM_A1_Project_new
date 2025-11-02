using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.Azure.Cosmos;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.VisualStudio.TestPlatform.TestHost;
using System;

namespace Todo.Api.IntegrationTests
{
    public class CustomWebApplicationFactory : WebApplicationFactory<Program>
    {
        protected override void ConfigureWebHost(IWebHostBuilder builder)
        {
            builder.ConfigureAppConfiguration((ctx, cfg) =>
            {
                cfg.AddEnvironmentVariables(); // read env vars from GitHub Actions
            });

            builder.ConfigureServices(services =>
            {
                var sp = services.BuildServiceProvider();
                var config = sp.GetRequiredService<IConfiguration>();

                var endpoint = config["COSMOS_DB_ENDPOINT"];
                var key = config["COSMOS_DB_KEY"];
                var database = config["COSMOS_DB_DATABASE"];
                var container = config["COSMOS_DB_CONTAINER"];

                if (string.IsNullOrWhiteSpace(endpoint) || string.IsNullOrWhiteSpace(key))
                    throw new InvalidOperationException("Missing Cosmos DB configuration.");

                services.AddSingleton(s =>
                {
                    var client = new CosmosClient(endpoint, key,
                        new CosmosClientOptions { ConnectionMode = ConnectionMode.Gateway });
                    return client;
                });

                // Optional: register a concrete repository if your app needs it directly
                // services.AddSingleton<ITodoRepository>(sp =>
                //     new CosmosTodoRepository(
                //         sp.GetRequiredService<CosmosClient>(),
                //         database!,
                //         container!));
            });
        }
    }
}
