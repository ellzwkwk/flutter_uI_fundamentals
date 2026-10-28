class Course {
  final int? id;
  final String code;
  final String title;
  final int credits;
  final String status;

  const Course({
    this.id,
    required this.code,
    required this.title,
    required this.credits,
    this.status = 'planned',
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      // MockAPI mengirim id sebagai string ("1"), sedangkan JSON lokal
      // tidak punya id sama sekali. int.tryParse menangani keduanya.
      id: int.tryParse('${json['id']}'),
      code: json['code'] as String,
      title: json['title'] as String,
      credits: json['credits'] as int,
      status: (json['status'] as String?) ?? 'planned',
    );
  }

  // id sengaja tidak ikut dikirim: id dibuat oleh server.
  Map<String, dynamic> toJson() => {
        'code': code,
        'title': title,
        'credits': credits,
        'status': status,
      };
}