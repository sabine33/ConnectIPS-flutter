import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:ninja/asymmetric/rsa/rsa.dart';
import "package:http/http.dart" as http;

import 'const.dart';

class ConnectIPSController {
  String txnId;
  String txnDate;
  String txnCurrency;
  int txnAmount;
  String refId;
  String remarks;
  String particulars;
  late String token;

  ConnectIPSController(
      {required this.txnId,
      required this.refId,
      required this.txnCurrency,
      required this.txnAmount,
      required this.txnDate,
      required this.remarks,
      required this.particulars}) {
    token = generateMessageSigningToken();
  }

  String generateConnectIPSMessage() {
    var message =
        "MERCHANTID=$MERCHANTID,APPID=$APPID,APPNAME=$APPNAME,TXNID=$txnId,TXNDATE=$txnDate,TXNCRNCY=$TXNCRNCY,TXNAMT=$txnAmount,REFERENCEID=$refId,REMARKS=$remarks,PARTICULARS=$particulars,TOKEN=TOKEN";
    return message;
  }

  String generateVerificationMessage() {
    var message =
        "MERCHANTID=$MERCHANTID,APPID=$APPID,REFERENCEID=$txnId,TXNAMT=$txnAmount";
    return message;
  }

  String generateVerificationToken() {
    final privateKey = RSAPrivateKey.fromPEM(privateKeyPEM);
    String message = generateVerificationToken();

    String encrypted =
        base64Encode(privateKey.signSsaPkcs1v15(message).toList());

    return encrypted;
  }

  Future<bool> verifyPayment() async {
    //app side verification disabled
    //implement on server side
    String token = generateVerificationToken();
    try {
      final body = {
        "merchantId": MERCHANTID,
        "appId": APPID,
        "referenceId": txnId,
        "txnAmt": txnAmount,
        "token": token,
      };

      String basicAuth = 'Basic ' +
          base64Encode('$VERIFICATION_ID:$VERIFICATION_PASSWORD'.codeUnits);

      final response = await http
          .post(Uri.parse(VERIFICATION_URL), body: json.encode(body), headers: {
        'Content-type': 'application/json',
        'Accept': 'application/json',
        "Authorization": basicAuth
      });
      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');
      return true;
    } catch (ex) {
      debugPrint("ERROR " + ex.toString());
      debugPrint(ex.toString());
      return false;
    }
  }

  String generateMessageSigningToken() {
    final privateKey = RSAPrivateKey.fromPEM(privateKeyPEM);
    // final publicKey = privateKey.toPublicKey;
    String message = generateConnectIPSMessage();
    String encrypted =
        base64Encode(privateKey.signSsaPkcs1v15(message).toList());
    debugPrint(encrypted);
    return encrypted;
  }

  String generateCIPSLoginPage() {
    return '''
  <form action="$BASEURL" method="post" id="cipsForm" hidden>
  <br />
  MERCHANT ID
  <input type="text" name="MERCHANTID" id="MERCHANTID" value="$MERCHANTID" />
  <br />
  APP ID
  <input type="text" name="APPID" id="APPID" value="$APPID" />
  <br />
  APP NAME
  <input type="text" name="APPNAME" id="APPNAME" value="$APPNAME" />
  <br />
  TXN ID
  <input type="text" name="TXNID" id="TXNID" value="$txnId" />
  <br />
  TXN DATE
  <input type="text" name="TXNDATE" id="TXNDATE" value="$txnDate" />
  <br />
  TXN CRNCY
  <input type="text" name="TXNCRNCY" id="TXNCRNCY" value="$TXNCRNCY" />
  <br />
  TXN AMT

  <input type="text" name="TXNAMT" id="TXNAMT" value="$txnAmount" />
  <br />
  REFERENCE ID
  <input type="text" name="REFERENCEID" id="REFERENCEID" value="$refId" />
  <br />
  REMARKS
  <input type="text" name="REMARKS" id="REMARKS" value="$remarks" />
  <br />
  PARTICULARS
  <input type="text" name="PARTICULARS" id="PARTICULARS" value="$particulars" />
  <br />
  TOKEN
  <input type="text" name="TOKEN" id="TOKEN" value="$token" />
  <br />
  <input type="submit" value="Submit" />
</form>
<script>
     function submitForm() {
         document.getElementById('cipsForm').submit();
     }
    submitForm();
</script>

''';
  }
}
