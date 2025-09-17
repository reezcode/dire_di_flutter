// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'app_router.dart';

abstract class _$AppRouter extends RootStackRouter {
  // ignore: unused_element
  _$AppRouter({super.navigatorKey});

  @override
  final Map<String, PageFactory> pagesMap = {
    CreateUserRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const CreateUserPage(),
      );
    },
    HomeRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const HomePage(),
      );
    },
    UserDetailsRoute.name: (routeData) {
      final pathParams = routeData.inheritedPathParams;
      final args = routeData.argsAs<UserDetailsRouteArgs>(
          orElse: () =>
              UserDetailsRouteArgs(userId: pathParams.getString('userId')));
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: UserDetailsPage(
          key: args.key,
          userId: args.userId,
        ),
      );
    },
  };
}

/// generated route for
/// [CreateUserPage]
class CreateUserRoute extends PageRouteInfo<void> {
  const CreateUserRoute({List<PageRouteInfo>? children})
      : super(
          CreateUserRoute.name,
          initialChildren: children,
        );

  static const String name = 'CreateUserRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [HomePage]
class HomeRoute extends PageRouteInfo<void> {
  const HomeRoute({List<PageRouteInfo>? children})
      : super(
          HomeRoute.name,
          initialChildren: children,
        );

  static const String name = 'HomeRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [UserDetailsPage]
class UserDetailsRoute extends PageRouteInfo<UserDetailsRouteArgs> {
  UserDetailsRoute({
    Key? key,
    required String userId,
    List<PageRouteInfo>? children,
  }) : super(
          UserDetailsRoute.name,
          args: UserDetailsRouteArgs(
            key: key,
            userId: userId,
          ),
          rawPathParams: {'userId': userId},
          initialChildren: children,
        );

  static const String name = 'UserDetailsRoute';

  static const PageInfo<UserDetailsRouteArgs> page =
      PageInfo<UserDetailsRouteArgs>(name);
}

class UserDetailsRouteArgs {
  const UserDetailsRouteArgs({
    this.key,
    required this.userId,
  });

  final Key? key;

  final String userId;

  @override
  String toString() {
    return 'UserDetailsRouteArgs{key: $key, userId: $userId}';
  }
}
