import 'dart:io';
import 'package:flutter/material.dart';

class ImageHelper {
  static ImageProvider getImageProvider(File f) {
    return f.existsSync()
        ? FileImage(f)
        : const AssetImage('assets/NoImageSelected.png');
  }
}
