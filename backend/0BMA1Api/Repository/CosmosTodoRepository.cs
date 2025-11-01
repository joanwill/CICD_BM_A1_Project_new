using Microsoft.Azure.Cosmos;
using System.Net;
using Microsoft.Azure.Cosmos.Linq;

namespace _0BMA1Api.Repository
{
    public interface ITodoRepository
    {
        Task<IEnumerable<TodoItem>> GetAllAsync();
        Task<TodoItem?> GetAsync(string id, string p);
        Task<TodoItem> CreateAsync(TodoItem item);
        Task<TodoItem?> UpdateAsync(TodoItem item);
        Task<bool> DeleteAsync(string id, string p);
    }

    public class CosmosTodoRepository : ITodoRepository
    {
        private readonly Container _container;
        public CosmosTodoRepository(Container container) => _container = container;

        public async Task<TodoItem> CreateAsync(TodoItem item)
        {
            var resp = await _container.CreateItemAsync(item, new PartitionKey(item.Pk));
            return resp.Resource;
        }
        public async Task<bool> DeleteAsync(string id, string p)
        {
            try
            {
                // Using "demo" partition for sample; in a real app you would pass userId
                await _container.DeleteItemAsync<TodoItem>(id, new PartitionKey("demo"));
                return true;
            }
            catch (CosmosException ex) when (ex.StatusCode == HttpStatusCode.NotFound) { return false; }
        }
        public async Task<IEnumerable<TodoItem>> GetAllAsync()
        {
            var query = _container.GetItemLinqQueryable<TodoItem>(allowSynchronousQueryExecution: true)
                                  .Where(t => t.Pk == "hotpartition")
                                  .ToFeedIterator();
            var results = new List<TodoItem>();
            while (query.HasMoreResults)
            {
                foreach (var item in await query.ReadNextAsync()) results.Add(item);
            }
            return results;
        }
        public async Task<TodoItem?> GetAsync(string id, string partitionKey)
        {
            try
            {
                var resp = await _container.ReadItemAsync<TodoItem>(id, new PartitionKey(partitionKey));
                return resp.Resource;
            }
            catch (CosmosException ex) when (ex.StatusCode == HttpStatusCode.NotFound) { return null; }
        }
        public async Task<TodoItem?> UpdateAsync(TodoItem item)
        {
            try
            {
                var resp = await _container.UpsertItemAsync(item, new PartitionKey(item.Pk));
                return resp.Resource;
            }
            catch (CosmosException ex) when (ex.StatusCode == HttpStatusCode.NotFound) { return null; }
        }
    }
}
