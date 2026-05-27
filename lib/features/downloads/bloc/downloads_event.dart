part of 'downloads_bloc.dart';

abstract class DownloadsEvent extends Equatable {
  const DownloadsEvent();

  @override
  List<Object?> get props => [];
}

class LoadDownloads extends DownloadsEvent {}

class AddDownload extends DownloadsEvent {
  final DownloadItem item;
  const AddDownload(this.item);

  @override
  List<Object?> get props => [item];
}

class StartDownloadWithStream extends DownloadsEvent {
  final DownloadItem item;
  final String streamUrl;

  const StartDownloadWithStream({
    required this.item,
    required this.streamUrl,
  });

  @override
  List<Object?> get props => [item, streamUrl];
}

class StartDownload extends DownloadsEvent {
  final String url;
  final DownloadType type;
  const StartDownload(this.url, this.type);

  @override
  List<Object?> get props => [url, type];
}

class UpdateDownloadProgress extends DownloadsEvent {
  final String id;
  final double progress;
  final String? size;
  final String? speed;
  final String? eta;
  const UpdateDownloadProgress(this.id, this.progress, {this.size, this.speed, this.eta});

  @override
  List<Object?> get props => [id, progress, size, speed, eta];
}

class DownloadFinished extends DownloadsEvent {
  final String id;
  final String filePath;
  final String? size;
  final String? duration;
  const DownloadFinished(this.id, this.filePath, {this.size, this.duration});

  @override
  List<Object?> get props => [id, filePath, size, duration];
}

class DownloadFailed extends DownloadsEvent {
  final String id;
  final String error;
  const DownloadFailed(this.id, this.error);

  @override
  List<Object?> get props => [id, error];
}

class DeleteDownload extends DownloadsEvent {
  final String id;
  const DeleteDownload(this.id);

  @override
  List<Object?> get props => [id];
}

class OpenFile extends DownloadsEvent {
  final DownloadItem item;
  const OpenFile(this.item);

  @override
  List<Object?> get props => [item];
}

class OpenFolder extends DownloadsEvent {
  final DownloadItem item;
  const OpenFolder(this.item);

  @override
  List<Object?> get props => [item];
}

class ShareFile extends DownloadsEvent {
  final DownloadItem item;
  const ShareFile(this.item);

  @override
  List<Object?> get props => [item];
}
