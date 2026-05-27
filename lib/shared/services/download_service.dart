import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'package:dio/dio.dart';
import 'package:open_filex_plus/open_filex_plus.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:device_info_plus/device_info_plus.dart';
import '../models/download_item.dart';

class DownloadService {
  final Dio _dio = Dio();
  final YoutubeExplode _yt = YoutubeExplode();

  Future<DownloadItem?> fetchMetadata(String url) async {
    DownloadType type = url.contains('mp3') ? DownloadType.audio : DownloadType.video;
    
    if (url.contains('youtube.com') || url.contains('youtu.be')) {
      return await _extractYoutube(url, type);
    } else {
      return await _extractDirectLink(url, type);
    }
  }

  Future<DownloadItem?> _extractYoutube(String url, DownloadType type) async {
    try {
      var video = await _yt.videos.get(VideoId(url));
      var manifest = await _yt.videos.streamsClient.getManifest(video.id);
      
      StreamInfo? stream;
      if (type == DownloadType.audio) {
        stream = manifest.audioOnly.withHighestBitrate();
      } else {
        stream = manifest.muxed.withHighestVideoQuality() ?? manifest.videoOnly.withHighestVideoQuality();
      }

      if (stream == null) return null;

      return DownloadItem(
        id: video.id.value,
        title: video.title,
        url: url,
        downloadUrl: stream.url.toString(),
        thumbnailUrl: video.thumbnails.highResUrl,
        duration: video.duration?.toString().split('.').first ?? "--:--",
        size: _formatBytes(stream.size.totalBytes.toInt()),
        type: type,
        platform: "YouTube",
        createdAt: DateTime.now(),
        status: DownloadStatus.pending
      );
    } catch (e) {
      return null;
    }
  }

  Future<DownloadItem?> _extractDirectLink(String url, DownloadType type) async {
    try {
      final response = await _dio.head(url);
      final contentType = response.headers.value('content-type') ?? '';
      if (!contentType.contains('video') && !contentType.contains('audio')) return null;

      final contentLength = int.tryParse(response.headers.value('content-length') ?? '0') ?? 0;
      return DownloadItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: "Direct_Media_${DateTime.now().second}",
        url: url,
        downloadUrl: url,
        size: _formatBytes(contentLength),
        type: type,
        platform: "Web",
        createdAt: DateTime.now(),
        status: DownloadStatus.pending
      );
    } catch (e) {
      return null;
    }
  }

  Future<void> downloadMedia({
    required DownloadItem item,
    String? customUrl,
    required Function(DownloadItem) onProgress,
    required Function(String, String) onCompleted,
    required Function(String) onError,
  }) async {
    try {
      if (!await _requestPermissions()) throw "Permission Denied";

      final dir = await getDownloadDirectory(item.type, item.platform);
      final extension = item.type == DownloadType.audio ? "mp3" : "mp4";
      final filePath = p.join(dir.path, "${item.title.replaceAll(RegExp(r'[^a-zA-Z0-9.\-]'), '_')}.$extension");
      
      final startTime = DateTime.now();
      String targetUrl = customUrl ?? item.downloadUrl ?? item.url;

      // If it's a YouTube item, we should refresh the download URL because they expire
      if (item.platform == "YouTube") {
        var video = await _yt.videos.get(VideoId(item.url));
        var manifest = await _yt.videos.streamsClient.getManifest(video.id);
        StreamInfo? stream;
        if (item.type == DownloadType.audio) {
          stream = manifest.audioOnly.withHighestBitrate();
        } else {
          stream = manifest.muxed.withHighestVideoQuality() ?? manifest.videoOnly.withHighestVideoQuality();
        }
        targetUrl = stream?.url.toString() ?? targetUrl;
      }

      await _dio.download(targetUrl, filePath, onReceiveProgress: (rec, total) {
        if (total != -1) {
          double progress = rec / total;
          double timeDiff = DateTime.now().difference(startTime).inSeconds.toDouble();
          if (timeDiff == 0) timeDiff = 1;
          double speed = rec / timeDiff;
          String speedStr = "${(speed / 1024 / 1024).toStringAsFixed(2)} MB/s";
          
          onProgress(item.copyWith(
            progress: progress,
            speed: speedStr,
            status: DownloadStatus.downloading
          ));
        }
      });

      if (await File(filePath).exists() && await File(filePath).length() > 0) {
        onCompleted(filePath, _formatBytes((await File(filePath).length()).toInt()));
      } else {
        throw "File download failed or empty";
      }
    } catch (e) {
      onError(e.toString());
    }
  }

  String _formatBytes(int bytes) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB"];
    var i = (math.log(bytes) / math.log(1024)).floor();
    return '${(bytes / math.pow(1024, i)).toStringAsFixed(1)} ${suffixes[i]}';
  }

  Future<bool> _requestPermissions() async {
    if (Platform.isIOS) return true;
    
    final deviceInfo = DeviceInfoPlugin();
    final androidInfo = await deviceInfo.androidInfo;
    
    if (androidInfo.version.sdkInt >= 33) {
       var videoStatus = await Permission.videos.request();
       var audioStatus = await Permission.audio.request();
       var photoStatus = await Permission.photos.request();
       return videoStatus.isGranted || audioStatus.isGranted || photoStatus.isGranted;
    } else if (androidInfo.version.sdkInt >= 30) {
       var status = await Permission.manageExternalStorage.request();
       if (status.isGranted) return true;
       status = await Permission.storage.request();
       return status.isGranted;
    }

    var status = await Permission.storage.request();
    return status.isGranted;
  }

  Future<Directory> getDownloadDirectory(DownloadType type, String? platform) async {
    Directory? base;
    if (Platform.isAndroid) {
      base = Directory('/storage/emulated/0/Download/Vexa');
    } else {
      base = await getApplicationDocumentsDirectory();
    }
    
    String sub = "Videos";
    if (type == DownloadType.audio) sub = "MP3";
    if (type == DownloadType.reel) sub = "Reels";

    final path = Directory(p.join(base.path, sub));
    if (!await path.exists()) await path.create(recursive: true);
    return path;
  }
  
  Future<void> openFile(String path) async {
    if (await File(path).exists()) {
      await OpenFilex.open(path);
    } else {
      throw "File not found at $path";
    }
  }

  Future<void> shareFile(String path, String title) async {
    if (await File(path).exists()) {
      await Share.shareXFiles([XFile(path)], text: title);
    }
  }
}

extension YtExtensions on Iterable<StreamInfo> {
  T withHighestBitrate<T extends AudioOnlyStreamInfo>() {
    final list = whereType<T>().toList();
    list.sort((a, b) => b.bitrate.compareTo(a.bitrate));
    return list.first;
  }
  
  T? withHighestVideoQuality<T extends VideoStreamInfo>() {
    final list = whereType<T>().toList();
    if (list.isEmpty) return null;
    list.sort((a, b) => b.videoQuality.index.compareTo(a.videoQuality.index));
    return list.first;
  }
}
