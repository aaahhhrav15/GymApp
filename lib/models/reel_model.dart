class ReelModel {
  final String id;
  final String caption;
  final String gymId;
  final String gymName; // populated from backend
  final String? gymLogo; // populated from backend
  final String videoUrl; // S3 URL for video
  final String s3Key; // S3 key for the video
  final DateTime createdAt;
  final DateTime updatedAt;

  ReelModel({
    required this.id,
    required this.caption,
    required this.gymId,
    required this.gymName,
    this.gymLogo,
    required this.videoUrl,
    required this.s3Key,
    required this.createdAt,
    required this.updatedAt,
  });

  // Legacy getters for backward compatibility
  String get customerId => gymId;
  String get customerName => gymName.isNotEmpty ? gymName : 'Unknown Gym';
  String? get profileImageUrl => gymLogo;

  // Getter for backward compatibility
  String get url => videoUrl;

  factory ReelModel.fromJson(Map<String, dynamic> json) {
    final String s3Key = json['s3Key'] ?? '';
    final String videoUrl = json['videoUrl'] ??
        (s3Key.isNotEmpty
            ? 'https://musclecrm-images.s3.ap-south-1.amazonaws.com/$s3Key'
            : '');

    // Extract gym information from the new API response
    String gymName = json['gymName']?.toString() ?? 'Unknown Gym';
    String? gymLogo = json['gymLogo']?.toString();
    String gymId = '';

    // Handle gymId - it can be either a string or a populated object
    if (json['gymId'] != null && json['gymId'] is Map) {
      final gymData = json['gymId'] as Map<String, dynamic>;
      gymId = gymData['_id']?.toString() ?? '';
      // If gymName is not provided directly, try to get it from populated gymId
      if (gymName == 'Unknown Gym') {
        gymName = gymData['name']?.toString() ?? 'Unknown Gym';
      }
      // If gymLogo is not provided directly, try to get it from populated gymId
      if (gymLogo == null) {
        gymLogo = gymData['logo']?.toString();
      }
    } else if (json['gymId'] != null) {
      gymId = json['gymId'].toString();
    }

    return ReelModel(
      id: json['_id'] ?? '',
      caption: json['caption'] ?? '',
      gymId: gymId,
      gymName: gymName,
      gymLogo: gymLogo,
      videoUrl: videoUrl,
      s3Key: s3Key,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'caption': caption,
      'gymId': gymId,
      'gymName': gymName,
      'gymLogo': gymLogo,
      'videoUrl': videoUrl,
      's3Key': s3Key,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  ReelModel copyWith({
    String? id,
    String? caption,
    String? gymId,
    String? gymName,
    String? gymLogo,
    String? videoUrl,
    String? s3Key,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ReelModel(
      id: id ?? this.id,
      caption: caption ?? this.caption,
      gymId: gymId ?? this.gymId,
      gymName: gymName ?? this.gymName,
      gymLogo: gymLogo ?? this.gymLogo,
      videoUrl: videoUrl ?? this.videoUrl,
      s3Key: s3Key ?? this.s3Key,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

// Remove the unused UserModel and CommentModel classes since we're not using them anymore
