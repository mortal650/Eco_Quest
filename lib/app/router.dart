import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/auth/auth_repository.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/signup_screen.dart';
import '../features/auth/presentation/forgot_password_screen.dart';
import '../features/dashboard/presentation/dashboard_screen.dart';
import '../features/student/presentation/student_classrooms_screen.dart';
import '../features/teacher/presentation/teacher_dashboard.dart';
import '../features/modules/presentation/module_list_screen.dart';
import '../features/modules/presentation/module_detail_screen.dart';
import '../features/modules/presentation/lesson_screen.dart';
import '../features/quiz/presentation/quiz_screen.dart';
import '../features/profile/presentation/profile_screen.dart';
import '../features/profile/presentation/profile_edit_screen.dart';
import '../features/ai_mentor/presentation/ai_mentor_screen.dart';
import '../features/leaderboard/presentation/leaderboard_screen.dart';
import '../features/achievements/presentation/achievements_screen.dart';
import '../features/teacher/presentation/create_classroom_screen.dart';
import '../features/teacher/presentation/classroom_detail_screen.dart';
import '../features/teacher/presentation/create_quiz_screen.dart';
import '../features/teacher/presentation/create_challenge_screen.dart';
import '../features/classroom/presentation/join_classroom_screen.dart';
import '../features/simulations/presentation/simulations_screen.dart';
import '../features/simulations/presentation/waste_segregation_sim.dart';
import '../features/simulations/presentation/carbon_footprint_sim.dart';
import '../features/simulations/presentation/renewable_energy_sim.dart';
import '../features/simulations/presentation/water_conservation_sim.dart';
import '../features/simulations/presentation/biodiversity_sim.dart';
import '../features/simulations/presentation/gut_microbiome_sim.dart';
import '../features/simulations/presentation/microplastics_sim.dart';
import '../features/simulations/presentation/gut_health_sim.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  final authNotifier = ValueNotifier<int>(0);

  ref.listen(authStateProvider, (_, __) {
    authNotifier.value++;
  });

  ref.listen(currentUserRoleProvider, (_, __) {
    authNotifier.value++;
  });

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/home',
    refreshListenable: authNotifier,
    redirect: (context, state) {
      final authState = ref.read(authStateProvider);
      final userRole = ref.read(currentUserRoleProvider).valueOrNull;

      final isLoggedIn = authState.valueOrNull != null;
      final isAuthRoute = state.matchedLocation == '/login' ||
          state.matchedLocation == '/signup' ||
          state.matchedLocation == '/forgot-password';

      if (!isLoggedIn && !isAuthRoute) return '/login';
      if (isLoggedIn && isAuthRoute) {
        if (userRole == 'teacher') return '/teacher-dashboard';
        return '/home';
      }

      if (isLoggedIn && state.matchedLocation == '/home') {
        if (userRole == 'teacher') return '/teacher-dashboard';
      }

      return null;
    },
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          final currentPath = state.matchedLocation;
          final isTeacher = currentPath.startsWith('/teacher');
          return ScaffoldWithBottomNavBar(
            navigationShell: navigationShell,
            isTeacher: isTeacher,
          );
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const DashboardScreen(),
              ),
              GoRoute(
                path: '/teacher-dashboard',
                builder: (context, state) => const TeacherDashboard(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/modules',
                builder: (context, state) => const ModuleListScreen(),
                routes: [
                  GoRoute(
                    path: ':id',
                    builder: (context, state) => ModuleDetailScreen(
                      moduleId: state.pathParameters['id']!,
                    ),
                    routes: [
                      GoRoute(
                        path: 'lesson/:lessonIndex',
                        builder: (context, state) => LessonScreen(
                          moduleId: state.pathParameters['id']!,
                          lessonIndex:
                              int.parse(state.pathParameters['lessonIndex']!),
                        ),
                      ),
                      GoRoute(
                        path: 'quiz',
                        builder: (context, state) => QuizScreen(
                          moduleId: state.pathParameters['id']!,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/classrooms',
                builder: (context, state) => const StudentClassroomsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/achievements',
                builder: (context, state) => const AchievementsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/mentor',
        builder: (context, state) => const AiMentorScreen(),
      ),
      GoRoute(
        path: '/leaderboard',
        builder: (context, state) => const LeaderboardScreen(),
      ),
      GoRoute(
        path: '/profile/edit',
        builder: (context, state) => const ProfileEditScreen(),
      ),
      GoRoute(
        path: '/teacher/create-classroom',
        builder: (context, state) => const CreateClassroomScreen(),
      ),
      GoRoute(
        path: '/teacher/classroom/:id',
        builder: (context, state) => ClassroomDetailScreen(
          classroomId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/teacher/create-quiz',
        builder: (context, state) => const CreateQuizScreen(),
      ),
      GoRoute(
        path: '/teacher/create-challenge',
        builder: (context, state) => const CreateChallengeScreen(),
      ),
      GoRoute(
        path: '/join-classroom',
        builder: (context, state) => const JoinClassroomScreen(),
      ),
      GoRoute(
        path: '/simulations',
        builder: (context, state) => const SimulationsScreen(),
      ),
      GoRoute(
        path: '/simulations/waste',
        builder: (context, state) => const WasteSegregationSim(),
      ),
      GoRoute(
        path: '/simulations/carbon',
        builder: (context, state) => const CarbonFootprintSim(),
      ),
      GoRoute(
        path: '/simulations/energy',
        builder: (context, state) => const RenewableEnergySim(),
      ),
      GoRoute(
        path: '/simulations/water',
        builder: (context, state) => const WaterConservationSim(),
      ),
      GoRoute(
        path: '/simulations/biodiversity',
        builder: (context, state) => const BiodiversitySimScreen(),
      ),
      GoRoute(
        path: '/simulations/gut-microbiome',
        builder: (context, state) => const GutMicrobiomeSimScreen(),
      ),
      GoRoute(
        path: '/simulations/microplastics',
        builder: (context, state) => const MicroplasticsSimScreen(),
      ),
      GoRoute(
        path: '/simulations/gut-health',
        builder: (context, state) => const GutHealthSimScreen(),
      ),
    ],
  );
});

class ScaffoldWithBottomNavBar extends StatelessWidget {
  const ScaffoldWithBottomNavBar({
    required this.navigationShell,
    this.isTeacher = false,
    super.key,
  });

  final StatefulNavigationShell navigationShell;
  final bool isTeacher;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) {
          int branchIndex = index;
          if (isTeacher) {
            if (index == 1) {
              branchIndex = 2;
            } else if (index == 2) {
              GoRouter.of(context).push('/teacher/create-classroom');
              return;
            } else if (index == 3) {
              branchIndex = 4;
            }
          }
          navigationShell.goBranch(
            branchIndex,
            initialLocation: branchIndex == navigationShell.currentIndex,
          );
        },
        destinations: isTeacher
            ? const [
                NavigationDestination(
                  icon: Icon(Icons.dashboard_outlined),
                  selectedIcon: Icon(Icons.dashboard),
                  label: 'Dashboard',
                ),
                NavigationDestination(
                  icon: Icon(Icons.class_outlined),
                  selectedIcon: Icon(Icons.class_),
                  label: 'Classrooms',
                ),
                NavigationDestination(
                  icon: Icon(Icons.add_circle_outline),
                  selectedIcon: Icon(Icons.add_circle),
                  label: 'Create',
                ),
                NavigationDestination(
                  icon: Icon(Icons.person_outline),
                  selectedIcon: Icon(Icons.person),
                  label: 'Profile',
                ),
              ]
            : const [
                NavigationDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home),
                  label: 'Home',
                ),
                NavigationDestination(
                  icon: Icon(Icons.menu_book_outlined),
                  selectedIcon: Icon(Icons.menu_book),
                  label: 'Modules',
                ),
                NavigationDestination(
                  icon: Icon(Icons.class_outlined),
                  selectedIcon: Icon(Icons.class_),
                  label: 'Classrooms',
                ),
                NavigationDestination(
                  icon: Icon(Icons.emoji_events_outlined),
                  selectedIcon: Icon(Icons.emoji_events),
                  label: 'Achieve',
                ),
                NavigationDestination(
                  icon: Icon(Icons.person_outline),
                  selectedIcon: Icon(Icons.person),
                  label: 'Profile',
                ),
              ],
      ),
    );
  }
}
