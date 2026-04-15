import 'package:go_router/go_router.dart';
import 'package:pmp/views/screens/new_nrm_request_screen.dart' show NewNrmRequestScreen;
import '../core/services/secure_storage_service.dart';
import '../views/screens/login_screen.dart';
import '../views/screens/dashboard_screen.dart';
import '../views/screens/new_hr_request_screen.dart';
import '../views/screens/report_breakdown_screen.dart';
import '../views/screens/hr_approve_screen.dart';
import '../views/screens/hr_close_ticket_screen.dart';
import '../views/screens/nrm_approve_screen.dart';
import '../views/screens/change_password_screen.dart';


class AppRouter {
  static final _storageService = SecureStorageService();

  static final GoRouter router = GoRouter(
    initialLocation: '/login', // Will be dynamic based on token later
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/change-password',
        builder: (context, state) => const ChangePasswordScreen(),
      ),
      GoRoute(
        path: '/hr/new',
        builder: (context, state) => const NewHrRequestScreen(),
      ),
      GoRoute(
        path: '/nrm/new',
        builder: (context, state) => const NewNrmRequestScreen(),
      ),
      GoRoute(
        path: '/maintenance/new',
        builder: (context, state) => const ReportBreakdownScreen(),
      ),
      GoRoute(
        path: '/hr/approve/:id',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          final extra = state.extra; // Could be HrRequestModel
          return HrApproveScreen(
            requestId: id,
            requestModel: extra != null ? (extra as dynamic) : null,
          );
        },
      ),
      GoRoute(
        path: '/hr/close/:id',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          final extra = state.extra;
          return HrCloseTicketScreen(
            requestId: id,
            requestModel: extra != null ? (extra as dynamic) : null,
          );
        },
      ),
      GoRoute(
        path: '/nrm/approve/:id',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          final extra = state.extra; // Could be NrmRequestModel
          return NrmApproveScreen(
            requestId: id,
            requestModel: extra != null ? (extra as dynamic) : null,
          );
        },
      ),
    ],
    redirect: (context, state) async {
      final token = await _storageService.getToken();
      final isLoggedIn = token != null && token.isNotEmpty;
      final isLoggingIn = state.uri.toString() == '/login';

      if (!isLoggedIn && !isLoggingIn) return '/login';
      if (isLoggedIn && isLoggingIn) return '/dashboard';

      return null;
    },
  );
}
