part of 'downloads_bloc.dart';

abstract class DownloadsState extends Equatable {
  const DownloadsState();
  
  @override
  List<Object?> get props => [];
}

class DownloadsInitial extends DownloadsState {}

class DownloadsLoading extends DownloadsState {}

class DownloadsLoaded extends DownloadsState {
  final List<DownloadItem> items;
  const DownloadsLoaded(this.items);

  @override
  List<Object?> get props => [items];
}

class DownloadsError extends DownloadsState {
  final String message;
  const DownloadsError(this.message);

  @override
  List<Object?> get props => [message];
}
