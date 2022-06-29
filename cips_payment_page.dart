import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'dart:convert';
import 'cips_controller.dart';
import 'const.dart';

class ConnectIPSPage extends StatefulWidget {
  final int txnAmt;
  final String txnID;
  final String txnDate;
  final String txnCRNCY;
  final String referenceID;
  final String remarks;
  final String particulars;

  const ConnectIPSPage(
      {Key? key,
      required this.txnAmt,
      required this.txnID,
      required this.txnDate,
      required this.txnCRNCY,
      required this.referenceID,
      required this.remarks,
      required this.particulars})
      : super(key: key);

  @override
  ConnectIPSPageState createState() {
    return ConnectIPSPageState();
  }
}

class ConnectIPSPageState extends State<ConnectIPSPage> {
  late ConnectIPSController connectIPSController;
  late WebViewController _controller;
  bool? _result;
  Map<String, String>? _paymentMeta;
  String? _status;
  @override
  void initState() {
    super.initState();
    debugPrint("${widget.txnID} ${widget.referenceID}");
    connectIPSController = ConnectIPSController(
        txnId: widget.txnID,
        refId: widget.referenceID,
        txnAmount: widget.txnAmt,
        particulars: widget.particulars,
        remarks: widget.remarks,
        txnCurrency: widget.txnCRNCY,
        txnDate: widget.txnDate);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          systemOverlayStyle: SystemUiOverlayStyle.light,
          title: const Text("ConnectIPS Payment"),
          leading: BackButton(
            onPressed: () async {
              if (_result != null && _result!) {
                if (await connectIPSController.verifyPayment()) {
                  Navigator.pop(context, {
                    "success": _result,
                    "paymentMeta": _paymentMeta,
                    "status": _status,
                  });
                } else {
                  Navigator.pop(context, null);
                }
              } else {
                Navigator.pop(context, null);
              }
            },
          ),
        ),
        body: WebView(
            initialUrl: 'about:blank',
            javascriptMode: JavascriptMode.unrestricted,
            onWebViewCreated: (WebViewController webViewController) async {
              _controller = webViewController;
              await _controller.clearCache();

              _loadHtmlFromAssets();
            },
            navigationDelegate: (NavigationRequest request) async {
              debugPrint("CIPS URL:" + request.url);

             
              if (request.url.startsWith(CALLBACKURL)) {
                //await connectIPSController.verifyPayment()) {
                //$payment_meta->paymentId && $payment_meta->payerID
                _paymentMeta = {
                  "payerID": widget.referenceID,
                  "paymentId": widget.txnID,
                  "token": widget.txnID,
                  "success": "true",
                  "reference": widget.referenceID,
                  "payment_status": "paid",
                  "method": connectIPS,
                  "verify": "true",
                };
                _result = true;

                Navigator.pop(context, {
                  "success": _result,
                  "paymentMeta": _paymentMeta,
                  "status": "paid",
                });

                return NavigationDecision.prevent;
              } 
            else if (request.url.startsWith(ERRORURL)) {
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: const Text("Error making payment.")));
              Navigator.pop(context, null);
            } else if (request.url.startsWith(HOMERROR)) {
              _paymentMeta = null;
              _result = false;

              Navigator.pop(context, {
                "success": _result,
                "paymentMeta": _paymentMeta,
                "status": "unpaid",
              });
            } else if (request.url.startsWith(UNAUTHERROR)) {
              _paymentMeta = null;
              _result = false;

              Navigator.pop(context, {
                "success": _result,
                "paymentMeta": _paymentMeta,
                "status": "unpaid",
              });
            }
            else {
              _result = false;
              _paymentMeta = null;
              return NavigationDecision.navigate;
            }

            return NavigationDecision.navigate;

            ));
  }

  _loadHtmlFromAssets() async {
    String fileText = connectIPSController.generateCIPSLoginPage();
    _controller.loadUrl(Uri.dataFromString(fileText,
            mimeType: 'text/html', encoding: Encoding.getByName('utf-8'))
        .toString());
  }
}
