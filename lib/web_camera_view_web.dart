import 'dart:js_interop';
import 'dart:ui_web' as ui_web;

import 'package:flutter/widgets.dart';
import 'package:web/web.dart' as web;

@JS('getHandVideoElement')
external JSAny? _getHandVideoElement();

bool _viewFactoryRegistered = false;

void registerCameraViewFactory(String viewType) {
  if (_viewFactoryRegistered) {
    return;
  }

  ui_web.platformViewRegistry.registerViewFactory(viewType, (int _) {
    final container = web.HTMLDivElement()
      ..style.width = '100%'
      ..style.height = '100%'
      ..style.overflow = 'hidden'
      ..style.backgroundColor = '#000';

    _attachVideoToContainer(container);
    return container;
  });

  _viewFactoryRegistered = true;
}

bool attachVideoIfAvailable() {
  final jsVideo = _getHandVideoElement();
  final video = jsVideo?.dartify();
  return video is web.HTMLElement;
}

Widget buildCameraView({Key? key, required String viewType}) {
  return HtmlElementView(
    key: key,
    viewType: viewType,
  );
}

void _attachVideoToContainer(web.HTMLDivElement container) {
  final jsVideo = _getHandVideoElement();
  final video = jsVideo?.dartify();
  if (video is! web.HTMLElement) {
    return;
  }

  video.style.width = '100%';
  video.style.height = '100%';
  video.style.objectFit = 'cover';
  if (video.parentElement != container) {
    container.append(video);
  }
}
