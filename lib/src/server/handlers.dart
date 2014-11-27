library miamitech.handlers;

import 'dart:async';
import 'dart:convert';
import 'dart:io' show HttpHeaders;

import 'package:shelf_exception_response/exception.dart';
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf_path/shelf_path.dart';
import 'page_generator.dart';

const Map headers = const {HttpHeaders.CONTENT_TYPE: 'text/html'};
var generator = new PageGenerator();

eventsPage(shelf.Request request) {
  try {
    Future generate = generator.generatePage(itemType: 'event');
    return generate.then((output) => new shelf.Response.ok(output, headers: headers));
  } catch (error) {
    print(error);
    throw new BadRequestException({'error':'body malformed'});
  }
}
