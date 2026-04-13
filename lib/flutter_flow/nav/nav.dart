import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

import '/main.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/lat_lng.dart';
import '/flutter_flow/place.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'serialization_util.dart';

import '/index.dart';

export 'package:go_router/go_router.dart';
export 'serialization_util.dart';

const kTransitionInfoKey = '__transition_info__';

GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

class AppStateNotifier extends ChangeNotifier {
  AppStateNotifier._();

  static AppStateNotifier? _instance;
  static AppStateNotifier get instance => _instance ??= AppStateNotifier._();

  bool showSplashImage = true;

  void stopShowingSplashImage() {
    showSplashImage = false;
    notifyListeners();
  }
}

GoRouter createRouter(AppStateNotifier appStateNotifier) => GoRouter(
      initialLocation: '/',
      debugLogDiagnostics: true,
      refreshListenable: appStateNotifier,
      navigatorKey: appNavigatorKey,
      errorBuilder: (context, state) => Container(),
      routes: [
        FFRoute(
          name: '_initialize',
          path: '/',
          builder: (context, _) => Container(),
        ),
        FFRoute(
          name: AuthenticationWidget.routeName,
          path: AuthenticationWidget.routePath,
          builder: (context, params) => AuthenticationWidget(),
        ),
        FFRoute(
          name: GuardiansInfoWidget.routeName,
          path: GuardiansInfoWidget.routePath,
          builder: (context, params) => GuardiansInfoWidget(),
        ),
        FFRoute(
          name: BusSupervisorDashboardWidget.routeName,
          path: BusSupervisorDashboardWidget.routePath,
          builder: (context, params) => BusSupervisorDashboardWidget(),
        ),
        FFRoute(
          name: AssignedStudentslistWidget.routeName,
          path: AssignedStudentslistWidget.routePath,
          builder: (context, params) => AssignedStudentslistWidget(),
        ),
        FFRoute(
          name: ConfirmBoardingWidget.routeName,
          path: ConfirmBoardingWidget.routePath,
          builder: (context, params) => ConfirmBoardingWidget(),
        ),
        FFRoute(
          name: UpdateStudentStatusWidget.routeName,
          path: UpdateStudentStatusWidget.routePath,
          builder: (context, params) => UpdateStudentStatusWidget(),
        ),
        FFRoute(
          name: ForgotPasswordWidget.routeName,
          path: ForgotPasswordWidget.routePath,
          builder: (context, params) => ForgotPasswordWidget(),
        ),
        FFRoute(
          name: ManageGuardiansWidget.routeName,
          path: ManageGuardiansWidget.routePath,
          builder: (context, params) => ManageGuardiansWidget(),
        ),
        FFRoute(
          name: CreateDailySchedulesWidget.routeName,
          path: CreateDailySchedulesWidget.routePath,
          builder: (context, params) => CreateDailySchedulesWidget(),
        ),
        FFRoute(
          name: ParentVerificationWidget.routeName,
          path: ParentVerificationWidget.routePath,
          builder: (context, params) => ParentVerificationWidget(),
        ),
        FFRoute(
          name: SchoolDashboardWidget.routeName,
          path: SchoolDashboardWidget.routePath,
          builder: (context, params) => SchoolDashboardWidget(),
        ),
        FFRoute(
          name: SplashWidget.routeName,
          path: SplashWidget.routePath,
          builder: (context, params) => SplashWidget(),
        ),
        FFRoute(
          name: BusWidget.routeName,
          path: BusWidget.routePath,
          builder: (context, params) => BusWidget(),
        ),
        FFRoute(
          name: ParentNotificationxxxxxWidget.routeName,
          path: ParentNotificationxxxxxWidget.routePath,
          builder: (context, params) => ParentNotificationxxxxxWidget(),
        ),
        FFRoute(
          name: DashWidget.routeName,
          path: DashWidget.routePath,
          builder: (context, params) => DashWidget(),
        ),
        FFRoute(
          name: RequestSxxxxxWidget.routeName,
          path: RequestSxxxxxWidget.routePath,
          builder: (context, params) => RequestSxxxxxWidget(),
        ),
        FFRoute(
          name: RequestSuccessfulWidget.routeName,
          path: RequestSuccessfulWidget.routePath,
          builder: (context, params) => RequestSuccessfulWidget(),
        ),
        FFRoute(
          name: SMmainWidget.routeName,
          path: SMmainWidget.routePath,
          builder: (context, params) => SMmainWidget(),
        ),
        FFRoute(
          name: ParentAddWidget.routeName,
          path: ParentAddWidget.routePath,
          builder: (context, params) => ParentAddWidget(),
        ),
        FFRoute(
          name: DriverMainWidget.routeName,
          path: DriverMainWidget.routePath,
          builder: (context, params) => DriverMainWidget(),
        ),
        FFRoute(
          name: DriverAddWidget.routeName,
          path: DriverAddWidget.routePath,
          builder: (context, params) => DriverAddWidget(),
        ),
        FFRoute(
          name: GuardiansMWidget.routeName,
          path: GuardiansMWidget.routePath,
          builder: (context, params) => GuardiansMWidget(),
        ),
        FFRoute(
          name: GuardianDetailsWidget.routeName,
          path: GuardianDetailsWidget.routePath,
          builder: (context, params) => GuardianDetailsWidget(),
        ),
        FFRoute(
          name: ApprovedGDWidget.routeName,
          path: ApprovedGDWidget.routePath,
          builder: (context, params) => ApprovedGDWidget(),
        ),
        FFRoute(
          name: TimeRequestDWidget.routeName,
          path: TimeRequestDWidget.routePath,
          builder: (context, params) => TimeRequestDWidget(),
        ),
        FFRoute(
          name: TimeRequestWidget.routeName,
          path: TimeRequestWidget.routePath,
          builder: (context, params) => TimeRequestWidget(),
        ),
        FFRoute(
          name: StudentAddWidget.routeName,
          path: StudentAddWidget.routePath,
          builder: (context, params) => StudentAddWidget(),
        ),
        FFRoute(
          name: ViewChildernWidget.routeName,
          path: ViewChildernWidget.routePath,
          builder: (context, params) => ViewChildernWidget(),
        ),
        FFRoute(
          name: BusAddWidget.routeName,
          path: BusAddWidget.routePath,
          builder: (context, params) => BusAddWidget(),
        ),
        FFRoute(
          name: RequestPicDroWidget.routeName,
          path: RequestPicDroWidget.routePath,
          builder: (context, params) => RequestPicDroWidget(),
        ),
        FFRoute(
          name: AddGuardianWidget.routeName,
          path: AddGuardianWidget.routePath,
          builder: (context, params) => AddGuardianWidget(),
        ),
        FFRoute(
          name: BusManageWidget.routeName,
          path: BusManageWidget.routePath,
          builder: (context, params) => BusManageWidget(),
        ),
        FFRoute(
          name: DriverManageWidget.routeName,
          path: DriverManageWidget.routePath,
          builder: (context, params) => DriverManageWidget(),
        ),
        FFRoute(
          name: ParentManageWidget.routeName,
          path: ParentManageWidget.routePath,
          builder: (context, params) => ParentManageWidget(),
        ),
        FFRoute(
          name: StudentManageWidget.routeName,
          path: StudentManageWidget.routePath,
          builder: (context, params) => StudentManageWidget(),
        ),
        FFRoute(
          name: CarWidget.routeName,
          path: CarWidget.routePath,
          builder: (context, params) => CarWidget(),
        ),
        FFRoute(
          name: DashGuardianWidget.routeName,
          path: DashGuardianWidget.routePath,
          builder: (context, params) => DashGuardianWidget(),
        ),
        FFRoute(
          name: RequestSuccessfulGWidget.routeName,
          path: RequestSuccessfulGWidget.routePath,
          builder: (context, params) => RequestSuccessfulGWidget(),
        ),
        FFRoute(
          name: ParentEditWidget.routeName,
          path: ParentEditWidget.routePath,
          builder: (context, params) => ParentEditWidget(),
        ),
        FFRoute(
          name: StudentEditWidget.routeName,
          path: StudentEditWidget.routePath,
          builder: (context, params) => StudentEditWidget(),
        ),
        FFRoute(
          name: DriverEditWidget.routeName,
          path: DriverEditWidget.routePath,
          builder: (context, params) => DriverEditWidget(),
        ),
        FFRoute(
          name: BusEditWidget.routeName,
          path: BusEditWidget.routePath,
          builder: (context, params) => BusEditWidget(),
        ),
        FFRoute(
          name: StudentStatusWidget.routeName,
          path: StudentStatusWidget.routePath,
          builder: (context, params) => StudentStatusWidget(),
        ),
        FFRoute(
          name: BusStatusWidget.routeName,
          path: BusStatusWidget.routePath,
          builder: (context, params) => BusStatusWidget(),
        ),
        FFRoute(
          name: ManageSchedulesWidget.routeName,
          path: ManageSchedulesWidget.routePath,
          builder: (context, params) => ManageSchedulesWidget(),
        ),
        FFRoute(
          name: BusStatusViewWidget.routeName,
          path: BusStatusViewWidget.routePath,
          builder: (context, params) => BusStatusViewWidget(),
        ),
        FFRoute(
          name: BusDriverProfileWidget.routeName,
          path: BusDriverProfileWidget.routePath,
          builder: (context, params) => BusDriverProfileWidget(),
        ),
        FFRoute(
          name: BusNotificationsWidget.routeName,
          path: BusNotificationsWidget.routePath,
          builder: (context, params) => BusNotificationsWidget(),
        ),
        FFRoute(
          name: ParentProfileWidget.routeName,
          path: ParentProfileWidget.routePath,
          builder: (context, params) => ParentProfileWidget(),
        ),
        FFRoute(
          name: AdminProfileWidget.routeName,
          path: AdminProfileWidget.routePath,
          builder: (context, params) => AdminProfileWidget(),
        ),
        FFRoute(
          name: ProfileGWidget.routeName,
          path: ProfileGWidget.routePath,
          builder: (context, params) => ProfileGWidget(),
        ),
        FFRoute(
          name: SchoolNotificationWidget.routeName,
          path: SchoolNotificationWidget.routePath,
          builder: (context, params) => SchoolNotificationWidget(),
        ),
        FFRoute(
          name: StudentStatusViewBusWidget.routeName,
          path: StudentStatusViewBusWidget.routePath,
          builder: (context, params) => StudentStatusViewBusWidget(),
        ),
        FFRoute(
          name: StudentStatusViewBusCarWidget.routeName,
          path: StudentStatusViewBusCarWidget.routePath,
          builder: (context, params) => StudentStatusViewBusCarWidget(),
        ),
        FFRoute(
          name: RequestStatusWidget.routeName,
          path: RequestStatusWidget.routePath,
          builder: (context, params) => RequestStatusWidget(),
        ),
        FFRoute(
          name: ViewChildernGWidget.routeName,
          path: ViewChildernGWidget.routePath,
          builder: (context, params) => ViewChildernGWidget(),
        ),
        FFRoute(
          name: BusGWidget.routeName,
          path: BusGWidget.routePath,
          builder: (context, params) => BusGWidget(),
        ),
        FFRoute(
          name: CarGWidget.routeName,
          path: CarGWidget.routePath,
          builder: (context, params) => CarGWidget(),
        ),
        FFRoute(
          name: ParentNotificationsWidget.routeName,
          path: ParentNotificationsWidget.routePath,
          builder: (context, params) => ParentNotificationsWidget(),
        ),
        FFRoute(
          name: NotificationsGWidget.routeName,
          path: NotificationsGWidget.routePath,
          builder: (context, params) => NotificationsGWidget(),
        )
      ].map((r) => r.toRoute(appStateNotifier)).toList(),
    );

extension NavParamExtensions on Map<String, String?> {
  Map<String, String> get withoutNulls => Map.fromEntries(
        entries
            .where((e) => e.value != null)
            .map((e) => MapEntry(e.key, e.value!)),
      );
}

extension NavigationExtensions on BuildContext {
  void safePop() {
    // If there is only one route on the stack, navigate to the initial
    // page instead of popping.
    if (canPop()) {
      pop();
    } else {
      go('/');
    }
  }
}

extension _GoRouterStateExtensions on GoRouterState {
  Map<String, dynamic> get extraMap =>
      extra != null ? extra as Map<String, dynamic> : {};
  Map<String, dynamic> get allParams => <String, dynamic>{}
    ..addAll(pathParameters)
    ..addAll(uri.queryParameters)
    ..addAll(extraMap);
  TransitionInfo get transitionInfo => extraMap.containsKey(kTransitionInfoKey)
      ? extraMap[kTransitionInfoKey] as TransitionInfo
      : TransitionInfo.appDefault();
}

class FFParameters {
  FFParameters(this.state, [this.asyncParams = const {}]);

  final GoRouterState state;
  final Map<String, Future<dynamic> Function(String)> asyncParams;

  Map<String, dynamic> futureParamValues = {};

  // Parameters are empty if the params map is empty or if the only parameter
  // present is the special extra parameter reserved for the transition info.
  bool get isEmpty =>
      state.allParams.isEmpty ||
      (state.allParams.length == 1 &&
          state.extraMap.containsKey(kTransitionInfoKey));
  bool isAsyncParam(MapEntry<String, dynamic> param) =>
      asyncParams.containsKey(param.key) && param.value is String;
  bool get hasFutures => state.allParams.entries.any(isAsyncParam);
  Future<bool> completeFutures() => Future.wait(
        state.allParams.entries.where(isAsyncParam).map(
          (param) async {
            final doc = await asyncParams[param.key]!(param.value)
                .onError((_, __) => null);
            if (doc != null) {
              futureParamValues[param.key] = doc;
              return true;
            }
            return false;
          },
        ),
      ).onError((_, __) => [false]).then((v) => v.every((e) => e));

  dynamic getParam<T>(
    String paramName,
    ParamType type, {
    bool isList = false,
  }) {
    if (futureParamValues.containsKey(paramName)) {
      return futureParamValues[paramName];
    }
    if (!state.allParams.containsKey(paramName)) {
      return null;
    }
    final param = state.allParams[paramName];
    // Got parameter from `extras`, so just directly return it.
    if (param is! String) {
      return param;
    }
    // Return serialized value.
    return deserializeParam<T>(
      param,
      type,
      isList,
    );
  }
}

class FFRoute {
  const FFRoute({
    required this.name,
    required this.path,
    required this.builder,
    this.requireAuth = false,
    this.asyncParams = const {},
    this.routes = const [],
  });

  final String name;
  final String path;
  final bool requireAuth;
  final Map<String, Future<dynamic> Function(String)> asyncParams;
  final Widget Function(BuildContext, FFParameters) builder;
  final List<GoRoute> routes;

  GoRoute toRoute(AppStateNotifier appStateNotifier) => GoRoute(
        name: name,
        path: path,
        pageBuilder: (context, state) {
          fixStatusBarOniOS16AndBelow(context);
          final ffParams = FFParameters(state, asyncParams);
          final page = ffParams.hasFutures
              ? FutureBuilder(
                  future: ffParams.completeFutures(),
                  builder: (context, _) => builder(context, ffParams),
                )
              : builder(context, ffParams);
          final child = page;

          final transitionInfo = state.transitionInfo;
          return transitionInfo.hasTransition
              ? CustomTransitionPage(
                  key: state.pageKey,
                  name: state.name,
                  child: child,
                  transitionDuration: transitionInfo.duration,
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) =>
                          PageTransition(
                    type: transitionInfo.transitionType,
                    duration: transitionInfo.duration,
                    reverseDuration: transitionInfo.duration,
                    alignment: transitionInfo.alignment,
                    child: child,
                  ).buildTransitions(
                    context,
                    animation,
                    secondaryAnimation,
                    child,
                  ),
                )
              : MaterialPage(
                  key: state.pageKey, name: state.name, child: child);
        },
        routes: routes,
      );
}

class TransitionInfo {
  const TransitionInfo({
    required this.hasTransition,
    this.transitionType = PageTransitionType.fade,
    this.duration = const Duration(milliseconds: 300),
    this.alignment,
  });

  final bool hasTransition;
  final PageTransitionType transitionType;
  final Duration duration;
  final Alignment? alignment;

  static TransitionInfo appDefault() => TransitionInfo(hasTransition: false);
}

class RootPageContext {
  const RootPageContext(this.isRootPage, [this.errorRoute]);
  final bool isRootPage;
  final String? errorRoute;

  static bool isInactiveRootPage(BuildContext context) {
    final rootPageContext = context.read<RootPageContext?>();
    final isRootPage = rootPageContext?.isRootPage ?? false;
    final location = GoRouterState.of(context).uri.toString();
    return isRootPage &&
        location != '/' &&
        location != rootPageContext?.errorRoute;
  }

  static Widget wrap(Widget child, {String? errorRoute}) => Provider.value(
        value: RootPageContext(true, errorRoute),
        child: child,
      );
}

extension GoRouterLocationExtension on GoRouter {
  String getCurrentLocation() {
    final RouteMatch lastMatch = routerDelegate.currentConfiguration.last;
    final RouteMatchList matchList = lastMatch is ImperativeRouteMatch
        ? lastMatch.matches
        : routerDelegate.currentConfiguration;
    return matchList.uri.toString();
  }
}
