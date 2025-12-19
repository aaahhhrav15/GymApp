class ResultModel {
  final String id;
  final String imageUrl; // Changed from imageBase64 to imageUrl
  final String s3Key; // Added s3Key field
  final String description;
  final double weight;
  final DateTime uploadDate;

  ResultModel({
    required this.id,
    required this.imageUrl,
    required this.s3Key,
    required this.description,
    required this.weight,
    required this.uploadDate,
  });

  // Getter for backward compatibility
  String get imageBase64 => imageUrl;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'imageUrl': imageUrl,
      's3Key': s3Key,
      'description': description,
      'weight': weight,
      'uploadDate': uploadDate.toIso8601String(),
    };
  }

  factory ResultModel.fromJson(Map<String, dynamic> json) {
    final String s3Key = json['s3Key'] ?? '';
    final String imageUrl = json['imageUrl'] ??
        (s3Key.isNotEmpty
            ? 'https://musclecrm-images.s3.ap-south-1.amazonaws.com/$s3Key'
            : '');

    return ResultModel(
      id: json['_id'] ?? json['id'], // Handle both _id and id
      imageUrl: imageUrl,
      s3Key: s3Key,
      description: json['description'] ?? '',
      weight: (json['weight'] ?? 0.0).toDouble(),
      uploadDate: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.parse(
              json['uploadDate'] ?? DateTime.now().toIso8601String()),
    );
  }

  ResultModel copyWith({
    String? id,
    String? imageUrl,
    String? s3Key,
    String? description,
    double? weight,
    DateTime? uploadDate,
  }) {
    return ResultModel(
      id: id ?? this.id,
      imageUrl: imageUrl ?? this.imageUrl,
      s3Key: s3Key ?? this.s3Key,
      description: description ?? this.description,
      weight: weight ?? this.weight,
      uploadDate: uploadDate ?? this.uploadDate,
    );
  }
}
