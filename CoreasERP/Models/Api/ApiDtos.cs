namespace CoreasERP.Models.Api;

public class ApiResultDto
{
    public bool Success { get; set; }
    public string Message { get; set; } = string.Empty;
}

public class ApiResultDto<T>
{
    public bool Success { get; set; }
    public string Message { get; set; } = string.Empty;
    public T? Data { get; set; }
}

public class LoginRequestDto
{
    public string Username { get; set; } = string.Empty;
    public string Password { get; set; } = string.Empty;
}

public class VerifyPasswordRequestDto
{
    public int IdUsuario { get; set; }
    public string Password { get; set; } = string.Empty;
}

public class AjusteStockSupervisadoRequestDto
{
    public int IdProducto { get; set; }
    public decimal NuevoStock { get; set; }
    public string Motivo { get; set; } = string.Empty;
    public string UsuarioSupervisor { get; set; } = string.Empty;
    public string ClaveSupervisor { get; set; } = string.Empty;
}

public class AgregarMaterialRequestDto
{
    public int IdProductoPadre { get; set; }
    public int IdProductoInsumo { get; set; }
    public decimal Cantidad { get; set; }
}

public class RegistrarVentaRequestDto
{
    public int IdCliente { get; set; }
    public int IdUsuario { get; set; }
    public string TipoComprobante { get; set; } = "Ticket";
    public string MetodoPago { get; set; } = "Efectivo";
    public decimal PagoCon { get; set; }
    public List<CoreasERP.Services.CartItemDto> Items { get; set; } = new();
}

public class RegistrarMermaLoteRequestDto
{
    public List<CoreasERP.Services.CartItemDto> Items { get; set; } = new();
    public string Motivo { get; set; } = string.Empty;
    public int IdSupervisor { get; set; }
    public int IdCajero { get; set; }
    public string? NotaAdicional { get; set; }
}

public class MermaLoteResultDto
{
    public bool Success { get; set; }
    public string Message { get; set; } = string.Empty;
    public decimal TotalCostoMerma { get; set; }
    public List<Merma> Mermas { get; set; } = new();
}

public class AbrirCajaRequestDto
{
    public int IdUsuario { get; set; }
    public decimal MontoInicial { get; set; }
}

public class ActualizarMontoInicialRequestDto
{
    public int IdCorte { get; set; }
    public decimal NuevoMontoInicial { get; set; }
}

public class CerrarCajaRequestDto
{
    public int IdCorte { get; set; }
    public decimal MontoFinal { get; set; }
    public decimal? Diferencia { get; set; }
}

public class RegistrarMovimientoCajaRequestDto
{
    public int IdUsuario { get; set; }
    public string Tipo { get; set; } = string.Empty;
    public decimal Monto { get; set; }
    public string Motivo { get; set; } = string.Empty;
    public int? IdCorte { get; set; }
}

public class GenerarResumenCorteRequestDto
{
    public int IdCorte { get; set; }
    public string TipoCorte { get; set; } = "CORTE X";
    public DesgloseDenominacionDto? DesgloseFisico { get; set; }
}

public class RegistrarCompraRequestDto
{
    public int IdProveedor { get; set; }
    public int IdUsuario { get; set; }
    public string NumFactura { get; set; } = string.Empty;
    public string? Observaciones { get; set; }
    public List<CoreasERP.Services.PurchaseItemDto> Items { get; set; } = new();
}

public class RegistrarAbonoRequestDto
{
    public int IdCuentaCobrar { get; set; }
    public int IdUsuario { get; set; }
    public decimal Monto { get; set; }
    public string MetodoPago { get; set; } = "Efectivo";
    public string? Notas { get; set; }
}

public class AplicarCambioPrecioRequestDto
{
    public int IdCambioPrecio { get; set; }
    public decimal? PrecioVentaFinal { get; set; }
}

public class SaveUsuarioRequestDto
{
    public Usuario Usuario { get; set; } = new();
    public string? NuevaClave { get; set; }
}

public class UploadImagenProductoDto
{
    public string NombreArchivo { get; set; } = string.Empty;
    public string ContenidoBase64 { get; set; } = string.Empty;
}

