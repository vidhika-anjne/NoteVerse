
class NoteModel {
  final String id;
  final String title;
  final String? fileUrl;
  final String? uploadedBy;
  final String? uploaderName;
  final String? uploaderPhoto;
  final int timestamp;
  final int upvoteCount;
  final int downvoteCount;
  final double rating;
  final int ratingCount;
  final int totalRating;
  final List<String> tags;

  NoteModel({
    required this.id,
    required this.title,
    this.fileUrl,
    this.uploadedBy,
    this.uploaderName,
    this.uploaderPhoto,
    this.timestamp = 0,
    this.upvoteCount = 0,
    this.downvoteCount = 0,
    this.rating = 0.0,
    this.ratingCount = 0,
    this.totalRating = 0,
    List<String>? tags,
  }) : tags = tags ?? const [];

  factory NoteModel.fromMap(String id, Map<dynamic, dynamic> data) {
    int parseInt(dynamic value) {
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    double parseDouble(dynamic value) {
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    final dynamicTags = data['tags'];
    final tags = dynamicTags is List
        ? dynamicTags.map((e) => e.toString()).toList()
        : <String>[];

    return NoteModel(
      id: id,
      title: (data['title'] ?? 'Untitled').toString(),
      fileUrl: data['fileUrl'] as String?,
      uploadedBy: data['uploadedBy'] as String?,
      uploaderName: data['uploaderName'] as String?,
      uploaderPhoto: (data['uploaderPhoto'] ?? data['photo']) as String?,
      timestamp: parseInt(data['timestamp']),
      upvoteCount: parseInt(data['upvoteCount']),
      downvoteCount: parseInt(data['downvoteCount']),
      rating: parseDouble(data['rating']),
      ratingCount: parseInt(data['ratingCount']),
      totalRating: parseInt(data['totalRating']),
      tags: tags,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'fileUrl': fileUrl,
      'uploadedBy': uploadedBy,
      'uploaderName': uploaderName,
      'uploaderPhoto': uploaderPhoto,
      'timestamp': timestamp,
      'upvoteCount': upvoteCount,
      'downvoteCount': downvoteCount,
      'rating': rating,
      'ratingCount': ratingCount,
      'totalRating': totalRating,
      'tags': tags,
    };
  }
}

