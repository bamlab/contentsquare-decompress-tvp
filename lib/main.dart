import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

main() {
  runApp(const DecompressionApp());
}

class DecompressionApp extends StatelessWidget {
  const DecompressionApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: DecompressionScreen(),
      ),
    );
  }
}

class DecompressionScreen extends StatefulWidget {
  const DecompressionScreen({Key? key}) : super(key: key);

  @override
  State<DecompressionScreen> createState() => _DecompressionScreenState();
}

class _DecompressionScreenState extends State<DecompressionScreen> {
  String? decompressedString;
  String? errorString;

  /// Decompress the given string using:
  ///  UTF-8 <-    ZLib   <- Base64
  /// String <- List<int> <- String
  void processTVP(String string) {
    setState(() {
      if (string.isEmpty) {
        decompressedString = null;
        errorString = null;
        return;
      }

      try {
        // Remove the native path if it was included
        const nativePathSeparator = '|flutter|';
        final nativePathSeparatorIndex = string.indexOf(nativePathSeparator);
        final String tvp;
        if (nativePathSeparatorIndex == -1) {
          tvp = string;
        } else {
          final endNativePathSeparatorIndex =
              nativePathSeparatorIndex + nativePathSeparator.length;
          tvp = string.substring(endNativePathSeparatorIndex);
        }

        decompressedString =
            utf8.decode(const ZLibDecoder().decodeBytes(base64.decode(tvp)));
        errorString = null;
      } catch (e) {
        decompressedString = null;
        errorString = 'Invalid path: \n$e';
      }
    });
  }

  void copyStringToClipboard() {
    Clipboard.setData(ClipboardData(text: decompressedString ?? errorString));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Decompressed text copied to clipboard")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 30.0),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                decoration: const InputDecoration(
                  hintText: 'Paste the compressed TVP',
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                ),
                maxLines: 200,
                onChanged: processTVP,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: SelectableText(
                        decompressedString ?? errorString ?? '',
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed:
                          decompressedString != null || errorString != null
                              ? copyStringToClipboard
                              : null,
                      child: const Text('Copy'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
