import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/erp_models.dart';

class OrderTicketScreen extends StatelessWidget {
  final VentaHistorialModel venta;
  final CustomerProfileModel customerProfile;
  final Color primaryColor;

  const OrderTicketScreen({
    super.key,
    required this.venta,
    required this.customerProfile,
    required this.primaryColor,
  });

  String _formatDate(DateTime dt) {
    final d = dt.day.toString().padLeft(2, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final y = dt.year.toString();
    final h = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    return '$d/$m/$y $h:$min';
  }

  @override
  Widget build(BuildContext context) {
    final c = primaryColor;
    final clienteNombre = venta.clienteNombre.trim().isNotEmpty
        ? venta.clienteNombre
        : (customerProfile.nombre.trim().isNotEmpty ? customerProfile.nombre : 'Cliente');
    final clienteTel = venta.clienteTelefono.trim().isNotEmpty
        ? venta.clienteTelefono
        : customerProfile.telefono;
    final isPickup = venta.esRetiroEnTienda;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 1,
        title: const Text(
          'Detalle de Pedido y Ticket',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
        ),
        actions: [
          IconButton(
            tooltip: 'Copiar Número de Ticket',
            onPressed: () {
              Clipboard.setData(ClipboardData(text: venta.numComprobante));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Número de ticket ${venta.numComprobante} copiado al portapapeles.'),
                  backgroundColor: c,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            icon: Icon(Icons.copy_rounded, color: c, size: 20),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 36),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner de Modalidad (Retiro en Tienda / Pick Up vs Envío a Domicilio)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isPickup ? const Color(0xFF0F172A) : c,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      isPickup ? Icons.storefront_rounded : Icons.local_shipping_rounded,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isPickup
                              ? 'MODALIDAD: RETIRO EN TIENDA (PICK UP)'
                              : 'MODALIDAD: ENVÍO A DOMICILIO',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 13,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isPickup
                              ? 'Presenta este Ticket de Compra en mostrador para retirar tu pedido.'
                              : (venta.direccionEntrega.isNotEmpty
                                  ? 'Entrega programada en: ${venta.direccionEntrega}'
                                  : 'Entrega a domicilio registrada en tu cuenta.'),
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 12,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // TICKET DE COMPRA OFICIAL (FACTURACIÓN)
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Cabecera del Ticket
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 22, 20, 16),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 64,
                          child: Image.asset(
                            'assets/images/logo.png',
                            fit: BoxFit.contain,
                            errorBuilder: (_, _, _) => Icon(
                              Icons.storefront_rounded,
                              size: 44,
                              color: c,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'SUPER TIENDA KENIA',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 17,
                            color: Color(0xFF0F172A),
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'TU AHORRO CAMPEÓN',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 11.5,
                            color: Color(0xFF64748B),
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'TICKET DE VENTA NO. ${venta.numComprobante}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 12.5,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  _buildDashedDivider(),

                  // Datos Generales del Comprobante
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    child: Column(
                      children: [
                        _ticketMetaRow('Fecha de Emisión:', _formatDate(venta.fechaHora)),
                        const SizedBox(height: 6),
                        _ticketMetaRow('Tipo de Comprobante:', 'Ticket'),
                        const SizedBox(height: 6),
                        _ticketMetaRow('Cliente:', clienteNombre),
                        if (clienteTel.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          _ticketMetaRow('Teléfono:', clienteTel),
                        ],
                        const SizedBox(height: 6),
                        _ticketMetaRow(
                          'Modalidad:',
                          isPickup ? 'Retiro en Tienda (Pick Up)' : 'Envío a Domicilio',
                        ),
                        const SizedBox(height: 6),
                        _ticketMetaRow(
                          'Método de Pago:',
                          isPickup ? 'Efectivo en tienda' : 'Efectivo contra entrega',
                        ),
                        const SizedBox(height: 6),
                        _ticketMetaRow('Estado del Pedido:', venta.estado),
                      ],
                    ),
                  ),

                  _buildDashedDivider(),

                  // Detalle de Artículos del Ticket
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'DETALLE DE PRODUCTOS',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF475569),
                            letterSpacing: 0.6,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            children: [
                              SizedBox(
                                width: 44,
                                child: Text(
                                  'CANT',
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  'DESCRIPCIÓN',
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 62,
                                child: Text(
                                  'P. UNIT',
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 68,
                                child: Text(
                                  'SUBTOTAL',
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (venta.detalles.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Expanded(
                                  child: Text(
                                    'Compra según comprobante registrado',
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF1E293B),
                                    ),
                                  ),
                                ),
                                Text(
                                  '\$${venta.total.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          ...venta.detalles.map((d) {
                            final cantLabel = d.cantidad % 1 == 0
                                ? d.cantidad.toInt().toString()
                                : d.cantidad.toStringAsFixed(2);
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        width: 44,
                                        child: Text(
                                          cantLabel,
                                          style: const TextStyle(
                                            fontSize: 12.5,
                                            fontWeight: FontWeight.w800,
                                            color: Color(0xFF0F172A),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              d.nombre,
                                              style: const TextStyle(
                                                fontSize: 12.5,
                                                fontWeight: FontWeight.w700,
                                                color: Color(0xFF0F172A),
                                              ),
                                            ),
                                            if (d.codigo.isNotEmpty)
                                              Text(
                                                'Código: ${d.codigo} • ${d.unidadMedida}',
                                                style: const TextStyle(
                                                  fontSize: 10.5,
                                                  color: Color(0xFF64748B),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        width: 62,
                                        child: Text(
                                          '\$${d.precioUnitario.toStringAsFixed(2)}',
                                          textAlign: TextAlign.right,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF334155),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 68,
                                        child: Text(
                                          '\$${d.subtotal.toStringAsFixed(2)}',
                                          textAlign: TextAlign.right,
                                          style: const TextStyle(
                                            fontSize: 12.5,
                                            fontWeight: FontWeight.w800,
                                            color: Color(0xFF0F172A),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (d.descuento > 0)
                                    Padding(
                                      padding: const EdgeInsets.only(left: 44, top: 2),
                                      child: Text(
                                        'Descuento aplicado: -\$${d.descuento.toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF15803D),
                                        ),
                                      ),
                                    ),
                                  const Divider(height: 12, color: Color(0xFFF1F5F9)),
                                ],
                              ),
                            );
                          }),
                      ],
                    ),
                  ),

                  _buildDashedDivider(),

                  // Totales (Ventas Gravadas sin mencionar IVA)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Ventas Exentas:',
                              style: TextStyle(fontSize: 12.5, color: Color(0xFF64748B)),
                            ),
                            const Text(
                              '\$0.00',
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF334155),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Ventas Gravadas:',
                              style: TextStyle(fontSize: 12.5, color: Color(0xFF64748B)),
                            ),
                            Text(
                              '\$${venta.total.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'TOTAL TICKET:',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            Text(
                              '\$${venta.total.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                color: c,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  _buildDashedDivider(),

                  // Bloque de Validación para Retiro en Tienda (Pick Up) / Control de Entrega
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 22),
                    child: Column(
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.qr_code_2_rounded, color: c, size: 22),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'CÓDIGO DE VERIFICACIÓN DE COMPRA',
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              // Representación gráfica de código de barras comercial
                              SizedBox(
                                height: 42,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: List.generate(38, (i) {
                                    final int w = (i % 4 == 0)
                                        ? 4
                                        : (i % 3 == 0 ? 2 : 1);
                                    return Container(
                                      width: w.toDouble(),
                                      height: 42,
                                      margin: const EdgeInsets.symmetric(horizontal: 1.4),
                                      color: const Color(0xFF0F172A),
                                    );
                                  }),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                venta.numComprobante,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13,
                                  letterSpacing: 2.0,
                                  color: Color(0xFF334155),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                isPickup
                                    ? 'Muestra este ticket digital en caja al retirar tus productos en tienda.'
                                    : 'Presenta este comprobante al repartidor al recibir tu pedido.',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Gracias por tu compra en Super Tienda Kenia',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _ticketMetaRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12.5,
            color: Color(0xFF64748B),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 12.5,
              color: Color(0xFF0F172A),
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDashedDivider() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final boxWidth = constraints.constrainWidth();
        const dashWidth = 6.0;
        const dashHeight = 1.2;
        final dashCount = (boxWidth / (2 * dashWidth)).floor();
        return Flex(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          direction: Axis.horizontal,
          children: List.generate(dashCount, (_) {
            return const SizedBox(
              width: dashWidth,
              height: dashHeight,
              child: DecoratedBox(
                decoration: BoxDecoration(color: Color(0xFFCBD5E1)),
              ),
            );
          }),
        );
      },
    );
  }
}
