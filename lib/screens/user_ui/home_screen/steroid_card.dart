import 'dart:async';
import 'dart:io';
import 'package:asthmaapp/constants/app_colors.dart';
import 'package:asthmaapp/main.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_media_downloader/flutter_media_downloader.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';

class SteroidCard extends StatefulWidget {
  final String? url;
  final String? path;
  final double? screenRatio;

  const SteroidCard({
    super.key,
    this.url,
    this.path,
    this.screenRatio,
  });

  _SteroidCardState createState() => _SteroidCardState();
}

class _SteroidCardState extends State<SteroidCard> with WidgetsBindingObserver {
  final Completer<PDFViewController> _controller =
      Completer<PDFViewController>();
  int? pages = 0;
  int? currentPage = 0;
  bool isReady = false;
  String errorMessage = '';
  int? _pages = 1, _totalPages;

  final _flutterMediaDownloaderPlugin = MediaDownload();

  Future<File> createFileOfPdfUrl() async {
    Completer<File> completer = Completer();
    logger.i("Start download file from internet!");
    try {
      final url = widget.url;
      final filename = url?.substring(url.lastIndexOf("/") + 1);
      var request = await HttpClient().getUrl(Uri.parse(url!));
      var response = await request.close();
      var bytes = await consolidateHttpClientResponseBytes(response);
      var dir = await getApplicationDocumentsDirectory();
      logger.i("Download files in directory: ${dir.path}");
      logger.i("${dir.path}/$filename");
      File file = File("${dir.path}/$filename");

      await file.writeAsBytes(bytes, flush: true);
      completer.complete(file);
    } catch (e) {
      throw Exception('Error parsing asset file!');
    }

    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    createFileOfPdfUrl();
    logger.d(widget.path);
    logger.d(widget.url);
    return Scaffold(
      backgroundColor: AppColors.primaryWhite,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: AppColors.primaryWhite,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Steroid Card',
            style: TextStyle(
              fontSize: widget.screenRatio! * 10,
              fontWeight: FontWeight.bold,
              fontFamily: 'Roboto',
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () {
              logger.i('Download');
              _flutterMediaDownloaderPlugin.downloadMedia(
                context,
                widget.url!,
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: <Widget>[
          PDFView(
            filePath: widget.path,
            enableSwipe: true,
            swipeHorizontal: true,
            autoSpacing: false,
            pageFling: true,
            pageSnap: true,
            defaultPage: currentPage!,
            fitPolicy: FitPolicy.BOTH,
            preventLinkNavigation:
                false, // if set to true the link is handled in flutter
            onRender: (_pages) {
              setState(() {
                _totalPages = _pages;
                pages = _pages;
                isReady = true;
              });
            },
            onError: (error) {
              setState(() {
                errorMessage = error.toString();
              });
              logger.e(error.toString());
            },
            onPageError: (page, error) {
              setState(() {
                errorMessage = '$page: ${error.toString()}';
              });
              logger.e('$page: ${error.toString()}');
            },
            onViewCreated: (PDFViewController pdfViewController) {
              _controller.complete(pdfViewController);
            },
            onLinkHandler: (String? uri) {
              logger.i('goto uri: $uri');
            },
            onPageChanged: (int? page, int? total) {
              setState(() {
                _pages = (page! + 1);
                _totalPages = total;
                currentPage = page;
              });
              logger.i('page change: $_pages/$_totalPages');
            },
          ),
          errorMessage.isEmpty
              ? !isReady
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : Container()
              : Center(
                  child: Text(errorMessage),
                ),
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Align(
              alignment: Alignment.topRight,
              child: Text('Page: $_pages of $_totalPages'),
            ),
          ),
        ],
      ),
    );
  }
}
