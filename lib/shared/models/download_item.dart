import 'package:equatable/equatable.dart';

enum DownloadStatus { pending, fetchingMetadata, downloading, completed, failed, paused }
enum DownloadType { video, audio, reel, shorts, clip }

class DownloadItem extends Equatable {
  final String id;
  final String title;
  final String url;
  final String? downloadUrl;
  final String? filePath;
  final String? thumbnailUrl;
  final DownloadStatus status;
  final double progress;
  final String? size;
  final String? duration;
  final DownloadType type;
  final DateTime createdAt;
  final String? extension;
  final String? platform;
  final String? quality;
  final String? speed;
  final String? eta;

  const DownloadItem({
    required this.id,
    required this.title,
    required this.url,
    this.downloadUrl,
    this.filePath,
    this.thumbnailUrl,
    this.status = DownloadStatus.pending,
    this.progress = 0.0,
    this.size,
    this.duration,
    required this.type,
    required this.createdAt,
    this.extension,
    this.platform,
    this.quality,
    this.speed,
    this.eta,
  });

  DownloadItem copyWith({
    String? id,
    String? title,
    String? downloadUrl,
    String? filePath,
    String? thumbnailUrl,
    DownloadStatus? status,
    double? progress,
    String? size,
    String? duration,
    DownloadType? type,
    String? extension,
    String? platform,
    String? quality,
    String? speed,
    String? eta,
  }) {
    return DownloadItem(
      id: id ?? this.id,
      title: title ?? this.title,
      url: url,
      downloadUrl: downloadUrl ?? this.downloadUrl,
      filePath: filePath ?? this.filePath,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      size: size ?? this.size,
      duration: duration ?? this.duration,
      type: type ?? this.type,
      createdAt: createdAt,
      extension: extension ?? this.extension,
      platform: platform ?? this.platform,
      quality: quality ?? this.quality,
      speed: speed ?? this.speed,
      eta: eta ?? this.eta,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        url,
        downloadUrl,
        filePath,
        thumbnailUrl,
        status,
        progress,
        size,
        duration,
        type,
        createdAt,
        extension,
        platform,
        quality,
        speed,
        eta,
      ];
}
