#import('lib/sqljocky.dart');
#import('lib/crypto/hash.dart');
#import('lib/crypto/sha1.dart');

void main() {
  Log log = new Log("main");
  {
    SyncConnection cnx = new SyncMySqlConnection();
    cnx.connect(user:'root').then((nothing) {
      print("connected");
      cnx.useDatabase('bob');
      Results results = cnx.query("select name as bob, age as wibble from people p");
      for (Field field in results.fields) {
        print("Field: ${field.name}");
      }
      for (List<Dynamic> row in results) {
        for (Dynamic field in row) {
          print(field);
        }
      }
      results = cnx.query("select * from blobby");
      Query query = cnx.prepare("select * from types");
      query.execute();
      query.close();
      cnx.close();
    });
  }

  log.debug("starting");
  AsyncConnection cnx = new AsyncMySqlConnection();
  cnx.connect(user:'test', password:'test', db:'bob').then((nothing) {
    log.debug("got connection");
    cnx.useDatabase('bob').then((dummy) {
      cnx.query("select name as bob, age as wibble from people p").then((Results results) {
        log.debug("queried");
        for (Field field in results.fields) {
          print("Field: ${field.name}");
        }
        for (List<Dynamic> row in results) {
          for (Dynamic field in row) {
            log.debug(field);
          }
        }
        cnx.query("select * from blobby").then((Results results2) {
          log.debug("queried");
          
          testPreparedQuery(cnx, log);
        });
      });
    });
  });
}

void testPreparedQuery(AsyncConnection cnx, Log log) {
  cnx.prepare("select * from types").then((query) {
    log.debug("prepared $query");
//    query[0] = 35;
    var res = query.execute().then((dummy) {
      query.close();
      log.debug("stmt closed");
      cnx.close();
    });
  });
}