import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MyBottomBar extends StatelessWidget {
  const MyBottomBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.list),
          label: 'Todos',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today),
          label: 'Select Day',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.add),
          label: 'Add Todo',
        ),
      ],
      onTap: (index) {
        final goRouter = GoRouter.of(context);
        switch (index) {
          case 0:
            goRouter.push('/todos');
            break;
          case 1:
            goRouter.push('/select_day');
            break;
          case 2:
            goRouter.push('/add_todo');
            break;
        }
      },
    );
  }
}
