namespace WarehouseAPI
{
    public class WarehouseOrder
    {
        public DateOnly Date { get; set; }

        public int OrderNumber { get; set; }

        public string? Summary { get; set; }
    }
}