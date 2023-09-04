/*
 * Copyright (c) 2022 Simform Solutions
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */
import 'package:any_link_preview/any_link_preview.dart';
import '../extensions/extensions.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../utils/constants.dart';

class LinkPreview extends StatelessWidget {
  const LinkPreview({
    Key? key,
    required this.url,
  }) : super(key: key);

  /// Provides url which is passed in message.
  final String url;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: 6, vertical: verticalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: verticalPadding),
            child: url.isImageUrl
                ? InkWell(
                    onTap: _onLinkTap,
                    child: Image.network(
                      url,
                      height: 120,
                      width: double.infinity,
                      fit: BoxFit.fitWidth,
                    ),
                  )
                : AnyLinkPreview(
                    link: url,
                    removeElevation: true,
                    onTap: _onLinkTap,
                    placeholderWidget: SizedBox(
                      height: MediaQuery.of(context).size.height * 0.25,
                      width: double.infinity,
                      child: const Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 1,
                        ),
                      ),
                    ),
                    backgroundColor: Colors.grey.shade200,
                    bodyStyle: const TextStyle(color: Colors.black),
                  ),
          ),
          const SizedBox(height: verticalPadding),
          InkWell(
            onTap: _onLinkTap,
            child: Text(
              url,
              style: const TextStyle(
                color: Colors.white,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onLinkTap() {
    _launchURL();
  }

  void _launchURL() async {
    final parsedUrl = Uri.parse(url);
    await canLaunchUrl(parsedUrl)
        ? await launchUrl(parsedUrl)
        : throw couldNotLunch;
  }
}
