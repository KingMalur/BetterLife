import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';

enum AlertReturnFull {Yes, No, Cancel}
enum AlertReturnDecide {Yes, No}

class CustomAlertDialog {
  static Future<AlertReturnDecide> showYesNoAlert(String title, BuildContext context) async {
    switch(
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return new SimpleDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
            elevation: 5.0,
            title: AutoSizeText(
              title,
              style: TextStyle(
                fontSize: 20.0,
              ),
              maxLines: 4,
              minFontSize: 15.0,
            ),
            children: <Widget>[
              Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  SimpleDialogOption(
                    child: AutoSizeText(
                      'Yes',
                      style: TextStyle(
                        fontSize: 15.0,
                      ),
                      maxLines: 1,
                      minFontSize: 10.0,
                    ),
                    onPressed: () {Navigator.of(context).pop(AlertReturnDecide.Yes);},
                  ),
                  VerticalDivider(),
                  SimpleDialogOption(
                    child: AutoSizeText(
                      'No',
                      style: TextStyle(
                        fontSize: 15.0,
                      ),
                      maxLines: 1,
                      minFontSize: 10.0,
                    ),
                    onPressed: () {Navigator.of(context).pop(AlertReturnDecide.No);},
                  ),
                ],
              ),
            ],
          );
        }
    )
    )
    {
      case AlertReturnDecide.Yes:
        return AlertReturnDecide.Yes;
        break;
      case AlertReturnDecide.No:
        return AlertReturnDecide.No;
        break;
    }
  }

  static Future<AlertReturnFull> showYesNoCancelAlert(String title, BuildContext context) async {
    switch(
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return new SimpleDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
            elevation: 5.0,
            title: AutoSizeText(
              title,
              style: TextStyle(
                fontSize: 20.0,
              ),
              maxLines: 4,
              minFontSize: 15.0,
            ),
            children: <Widget>[
              Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Row(
                          children: <Widget> [
                            SimpleDialogOption(
                              child: AutoSizeText(
                                'Yes',
                                style: TextStyle(
                                  fontSize: 15.0,
                                ),
                                maxLines: 1,
                                minFontSize: 10.0,
                              ),
                              onPressed: () {Navigator.of(context).pop(AlertReturnFull.Yes);},
                            ),
                            VerticalDivider(),
                            SimpleDialogOption(
                              child: AutoSizeText(
                                'No',
                                style: TextStyle(
                                  fontSize: 15.0,
                                ),
                                maxLines: 1,
                                minFontSize: 10.0,
                              ),
                              onPressed: () {Navigator.of(context).pop(AlertReturnFull.No);},
                            ),
                          ]
                      ),
                      Divider(),
                      SimpleDialogOption(
                        child: AutoSizeText(
                          'Cancel',
                          style: TextStyle(
                            fontSize: 15.0,
                          ),
                          maxLines: 1,
                          minFontSize: 10.0,
                        ),
                        onPressed: () {Navigator.of(context).pop(AlertReturnFull.Cancel);},
                      ),
                    ],
                  ),
                ],
              ),
            ],
          );
        }
    )
    )
    {
      case AlertReturnFull.Yes:
        return AlertReturnFull.Yes;
        break;
      case AlertReturnFull.No:
        return AlertReturnFull.No;
        break;
      case AlertReturnFull.Cancel:
        return AlertReturnFull.Cancel;
        break;
    }
  }
}
