import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:path/path.dart' as p;
import '../../../shared/models/download_item.dart';
import '../../../shared/services/download_service.dart';

part 'downloads_event.dart';
part 'downloads_state.dart';

class DownloadsBloc extends Bloc<DownloadsEvent, DownloadsState> {
  final DownloadService _downloadService;
  final List<DownloadItem> _items = [];

  DownloadsBloc(this._downloadService) : super(DownloadsInitial()) {
    on<LoadDownloads>((event, emit) {
      emit(DownloadsLoaded(List.from(_items)));
    });

    on<AddDownload>((event, emit) {
      _items.insert(0, event.item);
      emit(DownloadsLoaded(List.from(_items)));
      
      _startDownload(event.item);
    });

    on<StartDownload>((event, emit) async {
       final item = await _downloadService.fetchMetadata(event.url);
       if (item != null) {
         add(AddDownload(item.copyWith(type: event.type)));
       }
    });

    on<UpdateDownloadProgress>((event, emit) {
      final index = _items.indexWhere((i) => i.id == event.id);
      if (index != -1) {
        _items[index] = _items[index].copyWith(
          progress: event.progress,
          speed: event.speed,
          eta: event.eta,
          size: event.size ?? _items[index].size,
          status: DownloadStatus.downloading,
        );
        emit(DownloadsLoaded(List.from(_items)));
      }
    });

    on<DownloadFinished>((event, emit) {
      final index = _items.indexWhere((i) => i.id == event.id);
      if (index != -1) {
        _items[index] = _items[index].copyWith(
          filePath: event.filePath,
          size: event.size,
          status: DownloadStatus.completed,
          progress: 1.0,
        );
        emit(DownloadsLoaded(List.from(_items)));
      }
    });

    on<DownloadFailed>((event, emit) {
      final index = _items.indexWhere((i) => i.id == event.id);
      if (index != -1) {
        _items[index] = _items[index].copyWith(status: DownloadStatus.failed);
        emit(DownloadsLoaded(List.from(_items)));
      }
    });

    on<DeleteDownload>((event, emit) {
      _items.removeWhere((i) => i.id == event.id);
      emit(DownloadsLoaded(List.from(_items)));
    });

    on<OpenFile>((event, emit) async {
      try {
        await _downloadService.openFile(event.item.filePath!);
      } catch (e) {
        _items.removeWhere((i) => i.id == event.item.id);
        emit(DownloadsLoaded(List.from(_items)));
      }
    });

    on<OpenFolder>((event, emit) async {
        try {
          await _downloadService.openFile(p.dirname(event.item.filePath!));
        } catch (e) {
          _items.removeWhere((i) => i.id == event.item.id);
          emit(DownloadsLoaded(List.from(_items)));
        }
    });

    on<ShareFile>((event, emit) async {
      try {
        await _downloadService.shareFile(event.item.filePath!, event.item.title);
      } catch (e) {
        _items.removeWhere((i) => i.id == event.item.id);
        emit(DownloadsLoaded(List.from(_items)));
      }
    });
  }

  void _startDownload(DownloadItem item) {
    _downloadService.downloadMedia(
      item: item,
      onProgress: (updatedItem) {
        add(UpdateDownloadProgress(
          updatedItem.id, 
          updatedItem.progress, 
          size: updatedItem.size,
          speed: updatedItem.speed,
          eta: updatedItem.eta,
        ));
      },
      onCompleted: (filePath, size) {
        add(DownloadFinished(item.id, filePath, size: size));
      },
      onError: (error) {
        add(DownloadFailed(item.id, error));
      },
    );
  }
}
