import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import '../../core/theme/app_theme.dart';

class PlatformPdfViewer extends StatefulWidget {
  final String url;
  const PlatformPdfViewer({super.key, required this.url});

  @override
  State<PlatformPdfViewer> createState() => _PlatformPdfViewerState();
}

class _PlatformPdfViewerState extends State<PlatformPdfViewer> {
  String? _localPath;
  double _progress = 0;
  bool _loading = true;
  bool _isError = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _downloadAndLoad();
  }

  Future<void> _downloadAndLoad() async {
    try {
      setState(() { _loading = true; _isError = false; });

      final dir = await getTemporaryDirectory();
      final filePath = '${dir.path}/pdf_${widget.url.hashCode}.pdf';

      final file = File(filePath);
      if (!await file.exists()) {
        await Dio().download(
          widget.url,
          filePath,
          onReceiveProgress: (received, total) {
            if (total > 0 && mounted) {
              setState(() => _progress = received / total);
            }
          },
        );
      }

      if (mounted) setState(() { _localPath = filePath; _loading = false; });
    } catch (e) {
      if (mounted) {
        setState(() {
          _isError = true;
          _loading = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 12),
            Text(_errorMessage ?? 'Failed to load PDF',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _downloadAndLoad,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_loading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: AppTheme.primaryColor),
            const SizedBox(height: 16),
            Text(
              _progress > 0
                  ? 'Loading... ${(_progress * 100).toInt()}%'
                  : 'Preparing...',
              style: const TextStyle(color: Colors.grey),
            ),
            if (_progress > 0) ...[
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: LinearProgressIndicator(
                  value: _progress,
                  color: AppTheme.primaryColor,
                  backgroundColor: Colors.grey[200],
                ),
              ),
            ],
          ],
        ),
      );
    }

    return PDFView(
      filePath: _localPath!,
      enableSwipe: true,
      swipeHorizontal: false,
      autoSpacing: true,
      pageFling: true,
      fitPolicy: FitPolicy.BOTH,
      onError: (e) {
        if (mounted) {
          setState(() {
            _isError = true;
            _errorMessage = e.toString();
          });
        }
      },
    );
  }
}
