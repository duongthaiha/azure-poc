using Microsoft.AspNetCore.Mvc;

namespace OrderAPI.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class OrderController : ControllerBase
    {
        private static readonly string[] Summaries = new[]
        {
        "Clothes", "Item2"
        };

        private readonly ILogger<OrderController> _logger;

        public OrderController(ILogger<OrderController> logger)
        {
            _logger = logger;
        }

        [HttpGet(Name = "GetOrder")]
        public IEnumerable<Order> Get()
        {
            return Enumerable.Range(1, 5).Select(index => new Order
            {
                Date = DateOnly.FromDateTime(DateTime.Now.AddDays(index)),
                OrderNumber = Random.Shared.Next(-20, 55),
                Summary = Summaries[Random.Shared.Next(Summaries.Length)]
            })
            .ToArray();
        }
    }
}