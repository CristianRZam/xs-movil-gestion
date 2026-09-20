class ProductImage {

  final int id;
  final String imageUrl;
  final String altText;
  final bool isMain;
  final int orderNumber;

  const ProductImage({
    required this.id,
    required this.imageUrl,
    required this.altText,
    required this.isMain,
    required this.orderNumber,
  });

}