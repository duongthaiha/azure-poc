using Microsoft.AspNetCore.Mvc;

namespace WarehouseAPI.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class WarehouseOrderController : ControllerBase
    {
        private static readonly string[] Summaries = new[]
        {
        "Freezing", "Bracing", "Chilly", "Cool", "Mild", "Warm", "Balmy", "Hot", "Sweltering", "Scorching"
    };

        private readonly ILogger<WarehouseOrderController> _logger;

        public WarehouseOrderController(ILogger<WarehouseOrderController> logger)
        {
            _logger = logger;
        }

        [HttpGet(Name = "GetWarehouseOrder")]
        public WarehouseOrder Get()
        {
            var random = new Random();
            return new WarehouseOrder
            {
                Date = DateOnly.FromDateTime(DateTime.Now.AddDays(random.Next(1,5))),
                OrderNumber = Random.Shared.Next(-20, 55),
                Summary = Summaries[Random.Shared.Next(Summaries.Length)]
            };
        }
    }
}