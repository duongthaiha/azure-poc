using Microsoft.AspNetCore.Mvc;
using Newtonsoft.Json;

namespace FrontEndAPI.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class OrderController : ControllerBase
    {
        private static readonly string[] Summaries = new[]
        {
        "Clothes", "Bracing"
    };

        private readonly ILogger<OrderController> _logger;

        public OrderController(ILogger<OrderController> logger)
        {
            _logger = logger;
        }

        [HttpGet(Name = "GetOrder")]
        public async Task<Order> GetAsync()
        {
            //var handler = new HttpClientHandler()
            //{
            //    ServerCertificateCustomValidationCallback = HttpClientHandler.DangerousAcceptAnyServerCertificateValidator
            //};
            //using (var httpClient = new HttpClient(handler))
            //{
            //    var response = await httpClient.GetAsync("http://host.docker.internal:32779/warehouseorder");
            //    response.EnsureSuccessStatusCode();
            //    var responseBody = await response.Content.ReadAsStringAsync();
            //    var warehouseOrder = JsonConvert.DeserializeObject<WarehouseOrder>(responseBody);
            //    return new Order
            //    {
            //        Date = DateOnly.FromDateTime(DateTime.Now.AddDays(1)),
            //        OrderNumber = Random.Shared.Next(-20, 55),
            //        Summary = Summaries[Random.Shared.Next(Summaries.Length)],
            //        WarehouseOrder = warehouseOrder

            //    };
            //}
            return new Order
            {
                Date = DateOnly.FromDateTime(DateTime.Now.AddDays(1)),
                OrderNumber = Random.Shared.Next(-20, 55),
                Summary = Summaries[Random.Shared.Next(Summaries.Length)],
            

            };
        }
    }
}