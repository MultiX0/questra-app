import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:path_provider/path_provider.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:questra_app/core/services/updates_service.dart';
import 'package:questra_app/core/shared/widgets/background_widget.dart';
import 'package:questra_app/core/shared/widgets/beat_loader.dart';
import 'package:questra_app/imports.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';

class NewVersionPage extends ConsumerStatefulWidget {
  const NewVersionPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _NewVersionPageState();
}

class _NewVersionPageState extends ConsumerState<NewVersionPage> {
  bool isLoading = false;
  double downloadProgress = 0.0;
  bool isDownloading = false;
  String downloadStatus = "";
  String downloadedFilePath = "";
  String? taskId;
  final Dio dio = Dio();
  Timer? _progressUpdateTimer;

  // Port for communication with download isolate
  final ReceivePort _port = ReceivePort();

  @override
  void initState() {
    super.initState();
    _bindBackgroundIsolate();
    _initializeDownloader();
  }

  // Separate method to bind the background isolate
  void _bindBackgroundIsolate() {
    bool isSuccess = IsolateNameServer.registerPortWithName(_port.sendPort, 'downloader_send_port');

    if (!isSuccess) {
      // If registration failed, try to remove existing and register again
      IsolateNameServer.removePortNameMapping('downloader_send_port');
      isSuccess = IsolateNameServer.registerPortWithName(_port.sendPort, 'downloader_send_port');
      log("Port registration success after retry: $isSuccess");
    } else {
      log("Port registration success on first try");
    }

    // Listen for progress updates from the download isolate
    _port.listen((dynamic data) {
      log("Received data from port: $data");

      // Ensure data has the expected format
      if (data is List && data.length >= 3) {
        String id = data[0].toString();
        DownloadTaskStatus status = DownloadTaskStatus.fromInt(data[1] as int);
        int progress = data[2] as int;

        log('Download progress: $progress% for task $id with status ${status.toString()}');

        // Update the UI if this is our current task
        if (taskId != null && taskId == id) {
          if (mounted) {
            setState(() {
              downloadProgress = progress / 100;
              downloadStatus = "Downloading: $progress%";

              if (status == DownloadTaskStatus.complete) {
                isDownloading = false;
                downloadStatus = "Download complete!";
                _clearDownloadState();

                // Small delay to ensure the file is properly saved
                Future.delayed(const Duration(seconds: 1), () {
                  _installApk();
                });
              } else if (status == DownloadTaskStatus.failed) {
                isDownloading = false;
                isLoading = false;
                downloadStatus = "Download failed. Please try again.";
                _clearDownloadState();
              } else if (status == DownloadTaskStatus.running) {
                _saveDownloadState(id, progress);
              }
            });
          }
        }
      }
    });
  }

  void _initializeDownloader() async {
    // Initialize flutter_downloader
    await FlutterDownloader.initialize(
      debug: true, // You can set this to false in production
    );

    // Register a callback for download progress using the new binding mechanism
    FlutterDownloader.registerCallback(downloadCallback, step: 1);

    // Check for any ongoing downloads after initialization
    _checkForOngoingDownload();

    // Set up a fallback timer to check progress periodically
    _startProgressUpdateTimer();
  }

  void _startProgressUpdateTimer() {
    // Cancel any existing timer
    _progressUpdateTimer?.cancel();

    // Create a new timer that checks the download progress periodically
    _progressUpdateTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (isDownloading && taskId != null) {
        try {
          List<DownloadTask>? tasks = await FlutterDownloader.loadTasks();
          if (tasks != null) {
            for (var task in tasks) {
              if (task.taskId == taskId) {
                if (mounted) {
                  setState(() {
                    downloadProgress = task.progress / 100;
                    downloadStatus = "Downloading: ${task.progress}%";

                    if (task.status == DownloadTaskStatus.complete) {
                      isDownloading = false;
                      downloadStatus = "Download complete!";
                      timer.cancel();
                      _clearDownloadState();
                      _installApk();
                    } else if (task.status == DownloadTaskStatus.failed) {
                      isDownloading = false;
                      isLoading = false;
                      downloadStatus = "Download failed. Please try again.";
                      timer.cancel();
                      _clearDownloadState();
                    }
                  });
                }
                break;
              }
            }
          }
        } catch (e) {
          log("Error in progress timer: $e");
        }
      } else {
        // If not downloading, cancel the timer
        timer.cancel();
      }
    });
  }

  // This should be static and correctly annotated for isolate registration
  @pragma('vm:entry-point')
  static void downloadCallback(String id, int status, int progress) {
    log("Download callback - ID: $id, Status: $status, Progress: $progress");
    final SendPort? send = IsolateNameServer.lookupPortByName('downloader_send_port');
    if (send != null) {
      send.send([id, status, progress]);
    } else {
      log("Send port not found!");
    }
  }

  void _checkForOngoingDownload() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedTaskId = prefs.getString('ongoing_download_task_id');
    String? savedPath = prefs.getString('download_path');

    if (savedTaskId != null && savedPath != null) {
      log("Found ongoing download with ID: $savedTaskId and path: $savedPath");

      // Check if this task is still valid
      List<DownloadTask>? tasks = await FlutterDownloader.loadTasks();
      if (tasks != null) {
        for (var task in tasks) {
          if (task.taskId == savedTaskId) {
            log(
              "Found task in flutter_downloader with status: ${task.status} and progress: ${task.progress}%",
            );

            // Resume the task if it's still in progress
            if (task.status == DownloadTaskStatus.running ||
                task.status == DownloadTaskStatus.paused ||
                task.status == DownloadTaskStatus.enqueued) {
              setState(() {
                taskId = savedTaskId;
                isDownloading = true;
                downloadProgress = task.progress / 100;
                downloadStatus = "Downloading: ${task.progress}%";
                downloadedFilePath = savedPath;
              });

              // Start the fallback timer to update progress
              _startProgressUpdateTimer();
            }
            // If task is complete but installation didn't happen
            else if (task.status == DownloadTaskStatus.complete) {
              setState(() {
                downloadedFilePath = savedPath;
                downloadStatus = "Download complete!";
              });
              _installApk();
              _clearDownloadState();
            }
            break;
          }
        }
      }
    }
  }

  void _saveDownloadState(String id, int progress) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('ongoing_download_task_id', id);
    await prefs.setInt('download_progress', progress);
    await prefs.setString('download_path', downloadedFilePath);
  }

  void _clearDownloadState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('ongoing_download_task_id');
    await prefs.remove('download_progress');
    await prefs.remove('download_path');
  }

  Future<bool> _requestStoragePermission() async {
    var status = await Permission.storage.request();

    if (status.isGranted) {
      // If storage permission is granted, also request install packages permission on Android 8+
      if (Platform.isAndroid) {
        var installStatus = await Permission.requestInstallPackages.request();
        return installStatus.isGranted;
      }
      return true;
    }
    return false;
  }

  Future<void> downloadAndInstallUpdate() async {
    // Request permissions first
    bool hasPermission = await _requestStoragePermission();
    if (!hasPermission) {
      setState(() {
        downloadStatus = "Cannot download without storage permission";
      });
      return;
    }

    try {
      setState(() {
        isLoading = true;
        isDownloading = true;
        downloadStatus = "Fetching download link...";
      });

      // Step 1: Get the bit.ly link
      final bitlyUrl = await UpdatesService.getLastVersionLink();
      log("Bitly URL: $bitlyUrl");

      // Step 2: Follow the redirect to MediaFire
      final Response bitlyResponse = await dio.get(
        bitlyUrl,
        options: Options(followRedirects: true),
      );
      final String mediaFireUrl = bitlyResponse.realUri.toString();
      log("MediaFire URL: $mediaFireUrl");

      // Step 3: Fetch the MediaFire page to extract the download button
      final Response mediaFireResponse = await dio.get(mediaFireUrl);
      final document = html_parser.parse(mediaFireResponse.data);

      // Step 4: Extract the direct download link
      final downloadButton = document.querySelector('#downloadButton');
      if (downloadButton == null) {
        throw Exception("Could not find download button on MediaFire page");
      }

      final String directDownloadUrl = downloadButton.attributes['href'] ?? '';
      if (directDownloadUrl.isEmpty) {
        throw Exception("Download URL is empty");
      }

      log("Direct download URL: $directDownloadUrl");
      setState(() {
        downloadStatus = "Preparing to download...";
      });

      // Step 5: Get the download directory
      Directory? directory;
      if (Platform.isAndroid) {
        // For Android, use the Downloads directory for better visibility
        directory = Directory('/storage/emulated/0/Download');
        if (!await directory.exists()) {
          // Fallback to app's external storage
          directory = await getExternalStorageDirectory();
        }
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      if (directory == null) {
        throw Exception("Could not access storage directory");
      }

      // Make sure directory exists
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      final String apkPath = "${directory.path}/questra_new_version.apk";
      final String apkFilename = "questra_new_version.apk";

      log("Download directory: ${directory.path}");
      log("Full APK path: $apkPath");

      // Delete any existing file before downloading
      // final file = File(apkPath);
      // if (await file.exists()) {
      //   await file.delete();
      // }

      // Step 6: Use flutter_downloader to download the file
      final String? downloadTaskId = await FlutterDownloader.enqueue(
        url: directDownloadUrl,
        savedDir: directory.path,
        fileName: apkFilename,
        showNotification: true,
        openFileFromNotification: true,
        saveInPublicStorage: true,
      );

      if (downloadTaskId != null) {
        log("Download started with task ID: $downloadTaskId");

        setState(() {
          taskId = downloadTaskId;
          downloadedFilePath = apkPath;
        });

        // Save the task ID for background downloading
        _saveDownloadState(downloadTaskId, 0);

        // Start the timer for fallback progress updates
        _startProgressUpdateTimer();
      } else {
        throw Exception("Failed to start download");
      }
    } catch (e) {
      log("Error during update process: $e");
      setState(() {
        isLoading = false;
        isDownloading = false;
        downloadStatus = "Error: ${e.toString()}";
      });
    }
  }

  void _installApk() async {
    // First check if the file exists
    final file = File(downloadedFilePath);
    if (!await file.exists()) {
      setState(() {
        downloadStatus = "Installation file not found. Please try downloading again.";
        isLoading = false;
      });
      return;
    }

    try {
      log("Installing APK from path: $downloadedFilePath");

      if (Platform.isAndroid) {
        // Use platform channel to launch the installer
        const platform = MethodChannel('com.yourapp.apkinstaller');
        final result = await platform.invokeMethod('installApk', {'filePath': downloadedFilePath});

        log("Install result: $result");
        setState(() {
          isLoading = false;
          downloadStatus = "Installation started";
        });
      }
    } catch (e) {
      log("Error launching installation: $e");
      setState(() {
        downloadStatus =
            "Error launching installer. Please install manually from Downloads folder.";
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _progressUpdateTimer?.cancel();
    IsolateNameServer.removePortNameMapping('downloader_send_port');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundWidget(
      child: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(child: Image.asset(Assets.getImage('splash_icon.png'), fit: BoxFit.cover)),
                const SizedBox(height: 10),
                Text(
                  "NEW UPDATE",
                  style: TextStyle(
                    fontFamily: AppFonts.header,
                    fontSize: 20,
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  "تحديث جديد",
                  style: TextStyle(
                    fontFamily: AppFonts.header,
                    fontSize: 20,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 30),
                Text(
                  "Please download the latest version and delete the current version. The update contains some bug fixes",
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Text(
                  "الرجاء تحميل أخر اصدار وحذف الاصدار الحالي. التحديث يحتوي على اصلاح لبعض الأخطاء",
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),

                if (isDownloading) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Column(
                      children: [
                        LinearProgressIndicator(
                          value: downloadProgress,
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          "${(downloadProgress * 100).toInt()}%",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    downloadStatus,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                ],
                if (isLoading && !isDownloading) ...[
                  BeatLoader(),
                  const SizedBox(height: 10),
                  Text(
                    downloadStatus,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    textAlign: TextAlign.center,
                  ),
                ] else if (!isLoading && !isDownloading) ...[
                  SystemCardButton(onTap: downloadAndInstallUpdate, text: "Download"),
                  // Add an install button if download is complete but not installed
                  if (downloadedFilePath.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    SystemCardButton(onTap: _installApk, text: "Install"),
                  ],
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
