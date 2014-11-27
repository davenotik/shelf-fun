library shelftest.routes;

import 'handlers.dart' as handler;

import 'package:shelf_route/shelf_route.dart';

Router routes = new Router()
  ..get('/events', handler.eventsPage);