import 'package:flutter/material.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import '../../../core/constants/colors.dart';
import '../../../shared/widgets/glass_card.dart';

class DownloadOptionsSheet extends StatefulWidget {
  final String url;
  final String title;
  final String? thumbnailUrl;
  final StreamManifest manifest;
  final Function(StreamInfo stream, String extension, String quality) onDownload;

  const DownloadOptionsSheet({
    super.key,
    required this.url,
    required this.title,
    this.thumbnailUrl,
    required this.manifest,
    required this.onDownload,
  });

  @override
  State<DownloadOptionsSheet> createState() => _DownloadOptionsSheetState();
}

class _DownloadOptionsSheetState extends State<DownloadOptionsSheet> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                if (widget.thumbnailUrl != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      widget.thumbnailUrl!,
                      width: 80,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
                  ),
                const SizedBox(width: 15),
                Expanded(
                  child: Text(
                    widget.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
          TabBar(
            controller: _tabController,
            indicatorColor: AppColors.primary,
            labelColor: AppColors.textPrimary,
            unselectedLabelColor: AppColors.textSecondary,
            tabs: const [
              Tab(text: 'Video'),
              Tab(text: 'Audio'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildVideoList(),
                _buildAudioList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoList() {
    final muxed = widget.manifest.muxed.toList()
      ..sort((a, b) => b.videoQuality.index.compareTo(a.videoQuality.index));
    
    if (muxed.isEmpty) {
      return const Center(child: Text('No video streams found', style: TextStyle(color: AppColors.textSecondary)));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: muxed.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final stream = muxed[index];
        return _buildOptionTile(
          title: stream.qualityLabel,
          subtitle: '${stream.container.name.toUpperCase()} • ${stream.size.toString()}',
          onTap: () => widget.onDownload(
            stream, 
            stream.container.name, 
            stream.qualityLabel
          ),
        );
      },
    );
  }

  Widget _buildAudioList() {
    final audio = widget.manifest.audioOnly.toList()
      ..sort((a, b) => b.bitrate.compareTo(a.bitrate));
    
    if (audio.isEmpty) {
      return const Center(child: Text('No audio streams found', style: TextStyle(color: AppColors.textSecondary)));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: audio.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final stream = audio[index];
        return _buildOptionTile(
          title: '${stream.bitrate.kiloBitsPerSecond.toInt()} kbps',
          subtitle: '${stream.container.name.toUpperCase()} • ${stream.size.toString()}',
          onTap: () => widget.onDownload(
            stream, 
            stream.container.name == 'm4a' ? 'mp3' : stream.container.name, 
            '${stream.bitrate.kiloBitsPerSecond.toInt()}k'
          ),
        );
      },
    );
  }

  Widget _buildOptionTile({
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GlassCard(
      padding: EdgeInsets.zero,
      borderRadius: 15,
      child: ListTile(
        title: Text(title, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        trailing: const Icon(Icons.download_rounded, color: AppColors.primary),
        onTap: onTap,
      ),
    );
  }
}
