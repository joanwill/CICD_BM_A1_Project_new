using _0BMA1Api.Repository;
using Microsoft.AspNetCore.Mvc;
using System.Text.Json;

namespace _0BMA1Api.Controllers
{
    [ApiController]
    [Route("api")]
    public class ToDoController : ControllerBase
    {
        
        private static readonly string[] Summaries = new[]
        {
            "Freezing", "Bracing", "Chilly", "Cool", "Mild", "Warm", "Balmy", "Hot", "Sweltering", "Scorching"
        };

        private readonly ILogger<ToDoController> _logger;

        public ITodoRepository Repo { get; }

        public ToDoController(ITodoRepository repo, ILogger<ToDoController> logger)
        {
            _logger = logger;
            Repo = repo;
        }

        

        [HttpGet("todos", Name = "GetItem")]
        public IEnumerable<TodoItem> GetItem()
        {
            try
            {
                // uncomment this  to break the test
                //var item = Repo.GetAsync("string", "hotpartition");
                //if ( item == null) { return Enumerable.Empty<TodoItem>(); }


                //CARMEN uncomment this to show the changes once deployed
                //return Repo.GetAllAsync().GetAwaiter().GetResult().Take(1);
                return Repo.GetAllAsync().GetAwaiter().GetResult();
            }
            catch (Exception ex)
            {
                return Enumerable.Empty<TodoItem>();
            }

            //var result =  Enumerable.Range(1, 5).Select(index => new TodoItem
            //{
            //    Due = DateTime.Now.AddDays(index),
            //    UserId = Guid.NewGuid().ToString(),
            //    Description = Summaries[Random.Shared.Next(Summaries.Length)]
            //})
            //.ToArray();

            //var json = JsonSerializer.Serialize(result);
            //return result;
        }
        [HttpPost("todos")]
        [ProducesResponseType(typeof(TodoItem), StatusCodes.Status201Created)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        public async Task<ActionResult<TodoItem>> CreateItem([FromBody] TodoItem item)
        {
            if (string.IsNullOrWhiteSpace(item.Pk))
            {
                return BadRequest("Partition key (Pk) is required.");
            }

            var created = await Repo.CreateAsync(item);
            return CreatedAtRoute("GetItem", new { id = created.Id }, created);
        }


        //Hello
        [HttpDelete("todos/{id}")]
        [ProducesResponseType(StatusCodes.Status204NoContent)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> DeleteItem(string id)
        {
            // You may need to retrieve the partition key first (e.g., from a lookup)
            var item = await Repo.GetAsync(id, "hotpartition");
            if (item == null)
            {
                return NotFound();
            }

            await Repo.DeleteAsync(id, item.Pk); // Ensure DeleteAsync uses both id and pk
            return NoContent();
        }


        [HttpPut("todos/{id}")]
        [ProducesResponseType(typeof(TodoItem), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        public async Task<ActionResult<TodoItem>> UpdateItem(string id, [FromBody] TodoItem updated)
        {
            if (id != updated.Id)
            {
                return BadRequest("ID in URL does not match ID in body.");
            }

            var existing = await Repo.GetAsync(id, updated.Pk);
            if (existing == null)
            {
                return NotFound();
            }

            var result = await Repo.UpdateAsync(updated);
            return Ok(result);
        }

        [HttpGet("todos/{id}")]
        [ProducesResponseType(typeof(TodoItem), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<ActionResult<TodoItem>> GetItemById(string id)
        {
            // You may need to provide a default or lookup for the partition key
            var item = await Repo.GetAsync(id, "hotpartition"); // Replace "hotpartition" with dynamic if needed

            if (item == null)
            {
                return NotFound();
            }

            return Ok(item);
        }
    }
}
