namespace FrontEndAPI
{
    public class Order
    {
        public DateOnly Date { get; set; }

        public int OrderNumber { get; set; }



        public string? Summary { get; set; }

        public WarehouseOrder? WarehouseOrder { get; set; }
    }
    public class WarehouseOrder
    {
        public DateOnly Date { get; set; }

        public int OrderNumber { get; set; }

        public string? Summary { get; set; }
    }
}