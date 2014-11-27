import 'dart:io';
import 'dart:async';
import 'package:mustache/mustache.dart' as mustache;
import 'firebase.dart';
import '../shared/input_formatter.dart';
import '../shared/shared_util.dart';

class PageGenerator {
  /**
   * Generate a static page from a mustache template.
   *
   * Pass in a supported type.
   */
  generatePage({String itemType: 'event'}) {
    List items = [];
    String community = 'miamitech';
    String query = '';
    DateTime now = new DateTime.now();
    var jsonForTemplate;

    // Start at the beginning of today, and use a format our data model expects.
    var startAt = new DateTime(now.year, now.month, now.day).millisecondsSinceEpoch;

    switch (itemType) {
      case 'event':
        query = '/items_by_community_by_type/$community/event.json?orderBy="startDateTimePriority"&startAt="$startAt"&limitLast="20"';
        break;
      default:
        // Not a supported type, so let's get out of here.
        return null;
        break;
    }

    return Firebase.get(query).then((res) {
      Map itemsBlob = res;
      int count = 0;
      itemsBlob.forEach((k, v) {
        // Add the key, which is the item ID.
        var itemMap = v;
        itemMap['id'] = k;
        items.add(itemMap);
        count++;
      });

      items.forEach((i) {
        String teaser = InputFormatter.createTeaser(i['body'], 400);
        i['body'] = teaser;
        i['startDateTime'] = InputFormatter.formatDate(DateTime.parse(i['startDateTime']));
        i['encodedId'] = hashEncode(i['id']);
      });

       jsonForTemplate = {'items':items};
    }).catchError((e) => print("Firebase returned an error: $e")).then((e) {
        File file = new File('lib/src/server/templates/daily_digest.mustache');
        Future future = file.readAsString();
        return future.then((String contents) {
          // Parse the template.
          var template = mustache.parse(contents);
          String output = template.renderString(jsonForTemplate);

          return output;
        });
    });
//    print("DEBUG: ${debug.runtimeType}");
  }
}
