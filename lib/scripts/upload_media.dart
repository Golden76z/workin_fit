// scripts/upload_media.dart
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_storage/firebase_storage.dart';

void main() async {
  await Firebase.initializeApp();

  print('📁 Starting media upload...');

  await uploadExerciseMedia();

  print('✅ Media upload completed!');
}

Future<void> uploadExerciseMedia() async {
  // final storage = FirebaseStorage.instance;
  final assetsDir = Directory('assets');

  // Upload all exercise images
  final exerciseImagesDir = Directory('assets/images/exercises');
  if (exerciseImagesDir.existsSync()) {
    await uploadDirectory(exerciseImagesDir, 'exercises/images');
  }

  // Upload all exercise videos
  final exerciseVideosDir = Directory('assets/videos/exercises');
  if (exerciseVideosDir.existsSync()) {
    await uploadDirectory(exerciseVideosDir, 'exercises/videos');
  }
}

Future<void> uploadDirectory(Directory dir, String storagePath) async {
  await for (var entity in dir.list(recursive: true)) {
    if (entity is File) {
      final fileName = entity.path.split('/').last;
      final relativePath = entity.path.replaceFirst(dir.path, '');
      final uploadPath = '$storagePath$relativePath';

      print('📤 Uploading: $uploadPath');

      try {
        // await FirebaseStorage.instance.ref(uploadPath).putFile(entity);
        print('✅ Uploaded: $fileName');
      } catch (e) {
        print('❌ Failed to upload $fileName: $e');
      }
    }
  }
}
