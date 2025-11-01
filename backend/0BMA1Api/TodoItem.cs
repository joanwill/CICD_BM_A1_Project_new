using Newtonsoft.Json;

namespace _0BMA1Api
{
    public class TodoItem
    {
        [JsonProperty("id")]
        public string Id { get; init; } = Guid.NewGuid().ToString();
        public string Title { get; init; } = "";
        public string? Description { get; init; } = null;
        public bool IsDone { get; init; } = false;
        public int Priority { get; init; } = 1; // 1..3
        public DateTime? Due { get; init; } = null;
        public string UserId { get; init; } = "demo";
        [JsonProperty("pk")]
        public string Pk { get; init; }
    }
}
