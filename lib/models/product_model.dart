class Product {
  final String id;
  final String customerId;
  final String disclaimer;
  final String fastFacts;
  final String gymId;
  final String? imageBase64; // Made optional since we'll use imageUrl
  final String? imageUrl; // Added imageUrl field
  final List<String> keyBenefits;
  final String manufacturedBy;
  final String marketedBy;
  final String name;
  final String overview;
  final double price;
  final String shelfLife;
  final String sku;
  final String storage;
  final String usage;
  final String url;
  final DateTime createdAt;
  final DateTime updatedAt;

  Product({
    required this.id,
    required this.customerId,
    required this.disclaimer,
    required this.fastFacts,
    required this.gymId,
    this.imageBase64, // Made optional
    this.imageUrl, // Made optional
    required this.keyBenefits,
    required this.manufacturedBy,
    required this.marketedBy,
    required this.name,
    required this.overview,
    required this.price,
    required this.shelfLife,
    required this.sku,
    required this.storage,
    required this.usage,
    required this.url,
    required this.createdAt,
    required this.updatedAt,
  });

  // Helper getter to determine the image source
  String? get imageSource => imageUrl ?? imageBase64;
  bool get hasImageUrl => imageUrl != null && imageUrl!.isNotEmpty;
  bool get hasImageBase64 => imageBase64 != null && imageBase64!.isNotEmpty;

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['_id'] ?? '',
      customerId: json['customerId'] ?? '',
      disclaimer: json['disclaimer'] ?? '',
      fastFacts: json['fastFacts'] ?? '',
      gymId: json['gymId'] ?? '',
      imageBase64: json['imageBase64'], // Can be null
      imageUrl: json['imageUrl'] ?? json['image'], // Support both field names
      keyBenefits: List<String>.from(json['keyBenefits'] ?? []),
      manufacturedBy: json['manufacturedBy'] ?? '',
      marketedBy: json['marketedBy'] ?? '',
      name: json['name'] ?? '',
      overview: json['overview'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      shelfLife: json['shelfLife'] ?? '',
      sku: json['sku'] ?? '',
      storage: json['storage'] ?? '',
      usage: json['usage'] ?? '',
      url: json['url'] ?? '',
      createdAt:
          DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt:
          DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'customerId': customerId,
      'disclaimer': disclaimer,
      'fastFacts': fastFacts,
      'gymId': gymId,
      'imageBase64': imageBase64,
      'imageUrl': imageUrl,
      'keyBenefits': keyBenefits,
      'manufacturedBy': manufacturedBy,
      'marketedBy': marketedBy,
      'name': name,
      'overview': overview,
      'price': price,
      'shelfLife': shelfLife,
      'sku': sku,
      'storage': storage,
      'usage': usage,
      'url': url,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
