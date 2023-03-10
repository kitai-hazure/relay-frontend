import 'package:flutter/foundation.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class GraphQLEndPoints{
  ValueNotifier<GraphQLClient> getClient(){
    ValueNotifier<GraphQLClient> client = ValueNotifier(
      GraphQLClient(
        link: HttpLink("https://relay-backend.azurewebsites.net/graphql"),//TODO: ADD API LINK
        cache: GraphQLCache(),
      )
    );
    return client;
  }
  ValueNotifier<GraphQLClient> getClientWithToken(String token) {
    ValueNotifier<GraphQLClient> client = ValueNotifier(GraphQLClient(
      link: HttpLink(
        "https://relay-backend.azurewebsites.net/graphql", //TODO: ADD URL
        defaultHeaders: {
          'Authorization': 'Bearer $token',
        },
      ),
      cache: GraphQLCache(),
    ));

    return client;
  }
}