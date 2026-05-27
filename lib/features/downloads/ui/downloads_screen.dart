import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/colors.dart';
import '../../../shared/widgets/adaptive_widgets.dart';
import '../../../shared/widgets/glass_card.dart';
import '../bloc/downloads_bloc.dart';
import '../../../shared/models/download_item.dart';
import '../../../shared/services/download_service.dart';

class DownloadsScreen extends StatefulWidget {
  const DownloadsScreen({super.key});

  @override
  State<DownloadsScreen> createState() => _DownloadsScreenState();
}

class _DownloadsScreenState extends State<DownloadsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return AdaptiveScaffold(
      title: 'Manager',
      body: Column(
        children: [
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildDownloadList(DownloadType.video),
                _buildDownloadList(DownloadType.audio),
                _buildDownloadList(DownloadType.reel),
                _buildDownloadList(DownloadType.clip),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    final categories = ['Videos', 'Audio', 'Reels', 'Clips'];
    return Container(
      height: 45,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        dividerColor: Colors.transparent,
        indicator: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(10)),
        labelColor: Colors.white,
        unselectedLabelColor: AppColors.textSecondary,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        indicatorSize: TabBarIndicatorSize.tab,
        tabs: categories.map((c) => Tab(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Text(c, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold))))).toList(),
      ),
    );
  }

  Widget _buildDownloadList(DownloadType type) {
    return BlocBuilder<DownloadsBloc, DownloadsState>(
      builder: (context, state) {
        if (state is DownloadsLoaded) {
          final items = state.items.where((i) {
            if (type == DownloadType.video) return i.type == DownloadType.video || i.type == DownloadType.shorts;
            return i.type == type;
          }).toList();

          if (items.isEmpty) {
            return const Center(child: Text('Empty', style: TextStyle(color: AppColors.textSecondary)));
          }
          return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) => _buildDownloadCard(items[index]).animate().fadeIn(delay: (index * 50).ms).slideX(begin: 0.1, end: 0),
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _buildDownloadCard(DownloadItem item) {
    return GlassCard(
      padding: const EdgeInsets.all(12),
      borderRadius: 18,
      child: Column(
        children: [
          Row(
            children: [
              _buildThumbnail(item),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 4),
                    Text('${item.size ?? "..."} • ${item.platform ?? "Web"}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                    if (item.status == DownloadStatus.downloading) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(5),
                              child: LinearProgressIndicator(value: item.progress, backgroundColor: Colors.white10, valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary), minHeight: 4),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text('${(item.progress * 100).toInt()}%', style: const TextStyle(color: AppColors.textSecondary, fontSize: 10)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text('${item.speed ?? "0 B/s"} • ETA: ${item.eta ?? "--:--"}', style: const TextStyle(color: AppColors.primary, fontSize: 9, fontWeight: FontWeight.w600)),
                    ],
                  ],
                ),
              ),
              _buildActions(item),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildThumbnail(DownloadItem item) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(10)),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: item.thumbnailUrl != null
                ? CachedNetworkImage(imageUrl: item.thumbnailUrl!, fit: BoxFit.cover, errorWidget: (c, u, e) => _buildPlaceholder(item))
                : _buildPlaceholder(item),
          ),
          if (item.status == DownloadStatus.completed)
            const Center(child: Icon(Icons.play_arrow_rounded, color: Colors.white, size: 20)),
        ],
      ),
    );
  }

  Widget _buildPlaceholder(DownloadItem item) {
    return Center(child: Icon(item.type == DownloadType.audio ? Icons.music_note : Icons.play_circle, color: AppColors.primary.withValues(alpha: 0.4), size: 24));
  }

  Widget _buildActions(DownloadItem item) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert_rounded, color: AppColors.textSecondary),
      color: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      onSelected: (val) => _handleAction(val, item),
      itemBuilder: (context) => [
        if (item.status == DownloadStatus.completed) ...[
          const PopupMenuItem(value: 'play', child: Row(children: [Icon(Icons.play_arrow_rounded, size: 18), SizedBox(width: 10), Text('Play')])),
          const PopupMenuItem(value: 'share', child: Row(children: [Icon(Icons.share_rounded, size: 18), SizedBox(width: 10), Text('Share')])),
          const PopupMenuItem(value: 'folder', child: Row(children: [Icon(Icons.folder_open_rounded, size: 18), SizedBox(width: 10), Text('Show in Folder')])),
        ],
        const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete_outline_rounded, size: 18, color: Colors.redAccent), SizedBox(width: 10), Text('Delete', style: TextStyle(color: Colors.redAccent))])),
      ],
    );
  }

  void _handleAction(String action, DownloadItem item) async {
    final service = context.read<DownloadService>();
    switch (action) {
      case 'play':
        try {
          await service.openFile(item.filePath!);
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: ${e.toString()}')),
            );
          }
        }
        break;
      case 'share':
        service.shareFile(item.filePath!, item.title);
        break;
      case 'folder':
        // Show in folder implementation
        break;
      case 'delete':
        context.read<DownloadsBloc>().add(DeleteDownload(item.id));
        break;
    }
  }
}
