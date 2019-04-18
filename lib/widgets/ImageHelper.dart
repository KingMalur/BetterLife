import 'dart:io';
import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';

enum GetImageSource {Camera, Gallery, Reset}

class ImageHelper {
  static ImageProvider getImageProvider(File f) {
    return f.existsSync()
        ? FileImage(f)
        : const AssetImage('assets/NoImageSelected.png');
  }

  static Future getImageSource(BuildContext context) async {
    switch(
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return new SimpleDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
            elevation: 5.0,
            title: AutoSizeText(
              'Select Image Source',
              style: TextStyle(
                fontSize: 20.0,
              ),
              maxLines: 1,
              minFontSize: 15.0,
            ),
            children: <Widget>[
              Divider(),
              SimpleDialogOption(
                child: AutoSizeText(
                  'Camera',
                  style: TextStyle(
                    fontSize: 15.0,
                  ),
                  maxLines: 1,
                  minFontSize: 10.0,
                ),
                onPressed: () {Navigator.pop(context, GetImageSource.Camera);},
              ),
              Divider(),
              SimpleDialogOption(
                child: AutoSizeText(
                  'Gallery',
                  style: TextStyle(
                    fontSize: 15.0,
                  ),
                  maxLines: 1,
                  minFontSize: 10.0,
                ),
                onPressed: () {Navigator.pop(context, GetImageSource.Gallery);},
              ),
              Divider(),
              SimpleDialogOption(
                child: AutoSizeText(
                  'Reset Image',
                  style: TextStyle(
                    fontSize: 15.0,
                    color: Colors.red,
                  ),
                  maxLines: 1,
                  minFontSize: 10.0,
                ),
                onPressed: () {Navigator.pop(context, GetImageSource.Reset);},
              ),
            ],
          );
        }
    )
    )
    {
      case GetImageSource.Camera:
        return GetImageSource.Camera;
        break;
      case GetImageSource.Gallery:
        return GetImageSource.Gallery;
        break;
      case GetImageSource.Reset:
        return GetImageSource.Reset;
        break;
    }
  }
}
