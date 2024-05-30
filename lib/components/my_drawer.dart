import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  void logout() {
    FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.background,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(children: [
            DrawerHeader(
                child: Icon(
              Icons.favorite,
              color: Theme.of(context).colorScheme.inversePrimary,
            )),
            const SizedBox(height: 25),
            // Home
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: ListTile(
                leading: Icon(Icons.home,
                    color: Theme.of(context).colorScheme.inversePrimary),
                title: const Text("H O M E"),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ),
            // Profile
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: ListTile(
                leading: Icon(Icons.person,
                    color: Theme.of(context).colorScheme.inversePrimary),
                title: const Text("P R O F I L E"),
                onTap: () {
                  //  pop drawer
                  Navigator.pop(context);
                  // navigate to profile page
                  Navigator.pushNamed(context, '/profile');
                },
              ),
            ),
            // users
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: ListTile(
                leading: Icon(Icons.notifications,
                    color: Theme.of(context).colorScheme.inversePrimary),
                title: const Text("N O T I F I C A T I O N S"),
                onTap: () {
                  //  pop drawer
                  Navigator.pop(context);
                  // navigate to profile page
                  Navigator.pushNamed(context, '/notifications');
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: ListTile(
                leading: Icon(Icons.settings,
                    color: Theme.of(context).colorScheme.inversePrimary),
                title: const Text("S E T T I N G S"),
                onTap: () {
                  //  pop drawer
                  Navigator.pop(context);
                  // navigate to profile page
                  Navigator.pushNamed(context, '/settings');
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: ListTile(
                leading: Icon(Icons.select_all,
                    color: Theme.of(context).colorScheme.inversePrimary),
                title: const Text("S E L E C T M O D E"),
                onTap: () {
                  //  pop drawer
                  Navigator.pop(context);
                  // navigate to profile page
                  Navigator.pushNamed(context, '/selectmode');
                },
              ),
            ),
          ]),
          // Logout
          Padding(
            padding: const EdgeInsets.only(left: 8.0, bottom: 25),
            child: ListTile(
              leading: Icon(Icons.logout,
                  color: Theme.of(context).colorScheme.inversePrimary),
              title: const Text("L O G O U T"),
              onTap: () {
                // pop drawer
                Navigator.pop(context);
                // logout
                logout();
              },
            ),
          ),
        ],
      ),
    );
  }
}
