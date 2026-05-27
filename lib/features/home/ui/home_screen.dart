import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/colors.dart';
import '../../../shared/widgets/adaptive_widgets.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../downloads/bloc/downloads_bloc.dart';
import '../../../shared/models/download_item.dart';
import '../../../shared/services/download_service.dart';
import '../../settings/ui/settings_sheet.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _urlController = TextEditingController();
  DownloadType _selectedType = DownloadType.video;
  DownloadItem? _previewItem;
  bool _isFetching = false;

  @override
  void initState() {
    super.initState();
    _urlController.addListener(_onUrlChanged);
  }

  void _onUrlChanged() {
    final url = _urlController.text.trim();
    if (url.isEmpty) {
      setState(() => _previewItem = null);
      return;
    }

    if (url.startsWith('http')) {
      _fetchPreview(url);
    }
  }

  Future<void> _fetchPreview(String url) async {
    if (_isFetching) return;
    setState(() => _isFetching = true);
    
    try {
      final item = await context.read<DownloadService>().fetchMetadata(url);
      setState(() {
        _previewItem = item;
        _selectedType = item!.type;
        _isFetching = false;
      });
    } catch (e) {
      setState(() => _isFetching = false);
    }
  }

  void _startDownload() {
    if (_previewItem != null) {
      context.read<DownloadsBloc>().add(AddDownload(_previewItem!.copyWith(type: _selectedType)));
      _urlController.clear();
      setState(() => _previewItem = null);
      context.push('/downloads');
    }
  }

  void _showSettings() {
    if (Platform.isIOS) {
      showCupertinoModalPopup(context: context, builder: (context) => const SettingsSheet());
    } else {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => const SettingsSheet(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdaptiveScaffold(
      title: 'Vexa',
      actions: [
        Platform.isIOS
            ? CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: _showSettings,
                child: const Icon(CupertinoIcons.settings, color: Colors.white),
              )
            : IconButton(
                onPressed: _showSettings,
                icon: const HugeIcon(icon: HugeIcons.strokeRoundedSettings02, color: AppColors.textPrimary, size: 24),
              ),
      ],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 30),
            _buildInputSection(),
            const SizedBox(height: 25),
            if (_isFetching) _buildLoadingState(),
            if (_previewItem != null) _buildPreviewCard(),
            const SizedBox(height: 30),
            _buildRecentSection(),
          ],
        ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.1, end: 0),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Universal Downloader',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
        Text('Paste link to auto-detect and download', style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }

  Widget _buildInputSection() {
    return GlassCard(
      child: Column(
        children: [
          Platform.isIOS
              ? CupertinoTextField(
                  controller: _urlController,
                  placeholder: 'Paste URL here...',
                  placeholderStyle: const TextStyle(color: AppColors.textSecondary),
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: null,
                )
              : TextField(
                  controller: _urlController,
                  decoration: const InputDecoration(
                    hintText: 'Paste URL here...',
                    hintStyle: TextStyle(color: AppColors.textSecondary),
                    border: InputBorder.none,
                  ),
                  style: const TextStyle(color: AppColors.textPrimary),
                ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Platform.isIOS ? const CupertinoActivityIndicator() : const CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }

  Widget _buildPreviewCard() {
    return GlassCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Row(
            children: [
              _buildThumbnail(_previewItem!),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPlatformBadge(_previewItem!.platform ?? 'Web'),
                    const SizedBox(height: 4),
                    Text(
                      _previewItem!.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text('${_previewItem!.size} • ${_previewItem!.duration}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(child: _buildTypeToggle()),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: _startDownload,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                child: const Text('Download Now', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack).fadeIn();
  }

  Widget _buildThumbnail(DownloadItem item) {
    return Container(
      width: 100,
      height: 70,
      decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(12)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: item.thumbnailUrl != null
            ? CachedNetworkImage(imageUrl: item.thumbnailUrl!, fit: BoxFit.cover, errorWidget: (c, u, e) => _buildPlaceholder())
            : _buildPlaceholder(),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return const Center(child: Icon(Icons.play_circle_outline, color: AppColors.primary, size: 30));
  }

  Widget _buildPlatformBadge(String platform) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(6)),
      child: Text(platform.toUpperCase(), style: const TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildTypeToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          _buildToggleItem('Video', DownloadType.video),
          _buildToggleItem('Audio', DownloadType.audio),
        ],
      ),
    );
  }

  Widget _buildToggleItem(String label, DownloadType type) {
    final isSelected = _selectedType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedType = type),
        child: AnimatedContainer(
          duration: 300.ms,
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(color: isSelected ? AppColors.surface : Colors.transparent, borderRadius: BorderRadius.circular(10)),
          alignment: Alignment.center,
          child: Text(label, style: TextStyle(color: isSelected ? AppColors.textPrimary : AppColors.textSecondary, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, fontSize: 13)),
        ),
      ),
    );
  }

  Widget _buildRecentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Recent Downloads', style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
            TextButton(onPressed: () => context.push('/downloads'), child: const Text('See All', style: TextStyle(color: AppColors.accent))),
          ],
        ),
        BlocBuilder<DownloadsBloc, DownloadsState>(
          builder: (context, state) {
            if (state is DownloadsLoaded && state.items.isNotEmpty) {
              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: state.items.take(3).length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) => _buildRecentItem(state.items[index]),
              );
            }
            return const Center(child: Padding(padding: EdgeInsets.all(20), child: Text('No downloads yet', style: TextStyle(color: AppColors.textSecondary))));
          },
        ),
      ],
    );
  }

  Widget _buildRecentItem(DownloadItem item) {
    return GlassCard(
      padding: const EdgeInsets.all(12),
      borderRadius: 16,
      child: Row(
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(10)),
            child: AdaptiveIcon(
              iosIcon: item.type == DownloadType.audio ? CupertinoIcons.music_note : CupertinoIcons.play_fill,
              androidIcon: item.type == DownloadType.audio ? HugeIcons.strokeRoundedMusicNote01 : HugeIcons.strokeRoundedPlay,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w500, fontSize: 14)),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: item.progress,
                    backgroundColor: Colors.white10,
                    valueColor: AlwaysStoppedAnimation<Color>(item.status == DownloadStatus.completed ? Colors.green : AppColors.primary),
                    minHeight: 3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _urlController.removeListener(_onUrlChanged);
    _urlController.dispose();
    super.dispose();
  }
}
