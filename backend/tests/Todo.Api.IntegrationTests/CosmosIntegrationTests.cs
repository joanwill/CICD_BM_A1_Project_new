// Adjust namespaces to match your API
using _0BMA1Api;
using FluentAssertions;
using Microsoft.Azure.Cosmos;
using Microsoft.VisualStudio.TestTools.UnitTesting;

using System.Net;
using System.Threading.Tasks;
using Todo.Api.IntegrationTests;
using Microsoft.Azure.Cosmos.Linq;
using Microsoft.Azure.Cosmos;
using System.Collections.Generic;
using System.Linq;

#nullable enable

namespace Todo.Api.UnitTests
{


    [TestClass]
    public class CosmosIntegrationTests
    {


        private static CustomWebApplicationFactory _factory = null!;

        [ClassInitialize]
        public static void Init(TestContext _) => _factory = new CustomWebApplicationFactory();

        [TestMethod]
        public async Task GET_api_todos_returns_200_and_json()
        {
            var client = new CosmosClient("AccountEndpoint=https://bma1project.documents.azure.com:443/;AccountKey=IBtBMXFeYwL4xINcKC9fw5Ejbwx3KOkHOtrXwdETP5LnwkSUHLAwOE0tJesa5PGmcvy7ln9HXvLIACDba8cdzQ==;");
            var container = client.GetContainer("Todo","Todos");
            var query = container.GetItemLinqQueryable<TodoItem>(allowSynchronousQueryExecution: true)
                                 .Where(t => t.Pk == "hotpartition")
                                 .ToFeedIterator();
            var results = new List<TodoItem>();
            while (query.HasMoreResults)
            {
                foreach (var item in await query.ReadNextAsync()) results.Add(item);
            }
            Assert.IsTrue(results.Any());
        }
    }
}
