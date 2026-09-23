import 'package:app_movil_sistema/core/authorization/access_control.dart';
import 'package:app_movil_sistema/core/service_locator.dart';
import 'package:app_movil_sistema/features/notification/presentation/bloc/notification_cubit.dart';
import 'package:app_movil_sistema/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NotificationBell extends StatefulWidget {
  const NotificationBell({super.key});

  @override
  State<NotificationBell> createState() => _NotificationBellState();
}

class _NotificationBellState extends State<NotificationBell> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _canShow) {
        getIt<NotificationCubit>().loadUnreadCount();
      }
    });
  }

  bool get _canShow =>
      getIt.isRegistered<NotificationCubit>() &&
      getIt<AccessControl>().allows(AppCapability.notifications);

  @override
  Widget build(BuildContext context) {
    final access = getIt<AccessControl>();
    return ListenableBuilder(
      listenable: access,
      builder: (context, _) {
        if (!_canShow) return const SizedBox.shrink();
        return BlocBuilder<NotificationCubit, NotificationState>(
        bloc: getIt<NotificationCubit>(),
        buildWhen: (previous, current) =>
            previous.unreadCount != current.unreadCount,
        builder: (context, state) {
          final count = state.unreadCount;
          return IconButton(
            tooltip: count == 0
                ? 'Notificaciones'
                : '$count notificaciones sin leer',
            onPressed: () => Navigator.of(context).pushNamed(AppRoutes.notifications),
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.notifications_none_rounded, color: Colors.white),
                if (count > 0)
                  Positioned(
                    right: -8,
                    top: -8,
                    child: Container(
                      constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        border: Border.all(color: Colors.white, width: 1.5),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        count > 99 ? '99+' : '$count',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
        );
      },
    );
  }
}
