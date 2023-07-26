namespace OrderAPI
{
    public class Order
    {
        public DateOnly Date { get; set; }

        public int OrderNumber { get; set; }

        public string? Summary { get; set; }
    }
}