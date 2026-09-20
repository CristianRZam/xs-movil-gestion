import 'package:flutter/material.dart';
import 'package:app_movil_sistema/core/theme/app_colors.dart';
import 'package:app_movil_sistema/features/product/domain/entities/product.dart';

class ProductCard extends StatelessWidget {
  final Product product;

  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onWaste;
  final VoidCallback? onEnttry;
  final VoidCallback? onMovement;
  final VoidCallback? onAdjustment;

  const ProductCard({
    super.key,
    required this.product,
    this.onEdit,
    this.onDelete,
    this.onWaste,
    this.onEnttry,
    this.onMovement,
    this.onAdjustment,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final textColor = isDark ? AppColors.textDark : AppColors.textLight;

    final subColor = isDark ? Colors.white70 : Colors.grey.shade700;

    return Card(
      elevation: 3,
      color: isDark
          ? AppColors.dark
          : AppColors.white,
      shadowColor: Colors.black.withValues(alpha: .08),
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [

                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withValues( alpha: .15,),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.inventory_2_rounded,
                          size: 22,
                          color: AppColors.secondary,
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: Text(
                          product.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                            color: textColor,
                          ),
                        ),
                      ),
                    ],
                  ),


                  const SizedBox(height: 12),


                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [

                      _ChipInfo(
                        icon: Icons.category_outlined,
                        text: product.nameCategory,
                        color: Colors.indigo,
                      ),

                      _ChipInfo(
                        icon: product.active
                            ? Icons.check_circle
                            : Icons.cancel,
                        text: product.active
                            ? 'Activo'
                            : 'Inactivo',
                        color: product.active
                            ? Colors.green
                            : Colors.red,
                      ),
                    ],
                  ),


                  const SizedBox(height: 12),


                  Row(
                    children: [

                      Icon(
                        Icons.qr_code,
                        size: 16,
                        color: subColor,
                      ),

                      const SizedBox(width: 5),

                      Expanded(
                        child: Text(
                          product.code,
                          style: TextStyle(
                            color: subColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),

                    ],
                  ),


                  const SizedBox(height: 12),


                  Row(
                    children: [

                      Expanded(
                        child: _InfoItem(
                          icon: Icons.sell_outlined,
                          title: "Precio",
                          value:
                          "S/. ${product.basePrice.toStringAsFixed(2)}",
                          color: Colors.green,
                          isDark: isDark,
                        ),
                      ),


                      Expanded(
                        child: _InfoItem(
                          icon: Icons.inventory_2_outlined,
                          title: "Stock",
                          value:
                          product.totalStock.toString(),
                          color: Colors.blue,
                          isDark: isDark,
                        ),
                      ),

                    ],
                  ),

                ],
              ),
            ),

            PopupMenuButton<String>(
              onSelected: (value) {

                switch (value) {

                  case 'entry':
                    onEnttry?.call();
                    break;

                  case 'waste':
                    onWaste?.call();
                    break;

                  case 'adjustment':
                    onAdjustment?.call();
                    break;

                  case 'movement':
                    onMovement?.call();
                    break;

                  case 'edit':
                    onEdit?.call();
                    break;

                  case 'delete':
                    onDelete?.call();
                    break;

                }

              },
              itemBuilder: (_) => const [

                PopupMenuItem(
                  value: 'entry',
                  child: ListTile(
                    leading: Icon(Icons.add_box_outlined),
                    title:
                    Text('Agregar inventario'),
                    contentPadding:
                    EdgeInsets.zero,
                  ),
                ),

                PopupMenuItem(
                  value: 'waste',
                  child: ListTile(
                    leading: Icon(
                      Icons.remove_circle_outline,
                    ),
                    title: Text('Registrar merma'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),

                PopupMenuItem(
                  value: 'adjustment',
                  child: ListTile(
                    leading: Icon(
                      Icons.tune_outlined,
                    ),
                    title: Text(
                      'Ajustar inventario',
                    ),
                    contentPadding:
                    EdgeInsets.zero,
                  ),
                ),

                PopupMenuItem(
                  value: 'movement',
                  child: ListTile(
                    leading:
                    Icon(Icons.swap_horiz),
                    title: Text('Movimientos'),
                    contentPadding:
                    EdgeInsets.zero,
                  ),
                ),

                PopupMenuItem(
                  value: 'edit',
                  child: ListTile(
                    leading:
                    Icon(Icons.edit_outlined),
                    title: Text('Editar'),
                    contentPadding:
                    EdgeInsets.zero,
                  ),
                ),

                PopupMenuItem(
                  enabled: false,
                  height: 1,
                  padding: EdgeInsets.zero,
                  child: Divider(
                    thickness: 0.5,
                    color: Color(0xFFF2F2F2),
                  ),
                ),

                PopupMenuItem(
                  value: 'delete',
                  child: ListTile(
                    leading: Icon(
                      Icons.delete_outline,
                      color: Colors.red,
                    ),
                    title: Text(
                      'Eliminar',
                      style: TextStyle(
                        color: Colors.red,
                      ),
                    ),
                    contentPadding:
                    EdgeInsets.zero,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class _ChipInfo extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const _ChipInfo({
    required this.icon,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .10),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [

          Icon(
            icon,
            size: 14,
            color: color,
          ),

          const SizedBox(width: 5),

          Text(
            text,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;
  final bool isDark;

  const _InfoItem({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {

    return Column(
      children: [

        Icon(
          icon,
          color: color,
          size: 18,
        ),

        const SizedBox(height: 3),

        Text(
          title,
          style: TextStyle(
            fontSize: 11,
            color: isDark
                ? Colors.white60
                : Colors.grey,
          ),
        ),

        const SizedBox(height: 2),

        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDark
                ? Colors.white
                : Colors.black87,
          ),
        ),
      ],
    );
  }
}