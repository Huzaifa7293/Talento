class Comment {
  final String uid;
  final String comment;
  final String? userName;
  final String? userImage;
  final DateTime? timeStamp;

  Comment({
    required this.uid,
    required this.comment,
    this.userName,
    this.userImage,
    this.timeStamp,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      uid: json['uid'],
      comment: json['comment'],
      userName: json['userName'],
      userImage: json['userImage'],
      timeStamp: json['timeStamp'] != null
          ? DateTime.tryParse(json['timeStamp'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'comment': comment,
      'userName': userName,
      'userImage': userImage,
      'timeStamp': timeStamp?.toIso8601String(),
    };
  }

  Comment copyWith({
    String? uid,
    String? comment,
    String? userName,
    String? userImage,
    DateTime? timeStamp,
  }) {
    return Comment(
      uid: uid ?? this.uid,
      comment: comment ?? this.comment,
      userName: userName ?? this.userName,
      userImage: userImage ?? this.userImage,
      timeStamp: timeStamp ?? this.timeStamp,
    );
  }
}
