import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobx/mobx.dart';
import 'package:mobx_restfull_api/Pages/posts_list.dart';

import '../Models/user.dart';
import '../Stores/user_store.dart';
UserStore _store = UserStore();

class UserList extends StatefulWidget {

  UserList() {
    _store.getTheUsers();
  }

  @override
  State<UserList> createState() => _UserListState();
}

class _UserListState extends State<UserList> {


  @override
  Widget build(BuildContext context) {
    final future = _store.userListFuture;
    return Observer(
      // ignore: missing_return
      builder: (_) {
        switch (future.status) {
          case FutureStatus.pending:
            return _pendingUsers();

          case FutureStatus.fulfilled:
            final List<User> users = future.result;
            return _loadUsers(users,_refresh);

          case FutureStatus.rejected:
            return _failed(_refresh);
            break;
        }
      },
    );
  }

  Future _refresh() => _store.fetchUsers();
}



class _pendingUsers extends StatelessWidget {
  const _pendingUsers({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(),
    );
  }
}

class _failed extends StatelessWidget {
  final Future Function() refresh;
  const _failed(this.refresh, {
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            'Failed to load items.',
            style: TextStyle(color: Colors.red),
          ),
          SizedBox(
            height: 10,
          ),
          ElevatedButton(
            child: const Text('Tap to retry'),
            onPressed: refresh,
          )
        ],
      ),
    );
  }
}


class _loadUsers extends StatelessWidget {
  final List<User> users;
  final Future Function() refresh;
  const _loadUsers(this.users, this.refresh, {
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh:refresh,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];
          return userCard(user: user);
        },
      ),
    );
  }
}

class userCard extends StatelessWidget {
  const userCard({
    Key key,
    @required this.user,
  }) : super(key: key);

  final User user;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Image.network(user.avatar),
        title: Text(
          user.name,
          style:
              TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          user.email,
          style:
              TextStyle( fontWeight: FontWeight.w400),
        ),
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => PostsList(user.id),
          ));
        },
        trailing: Icon(Icons.person),
      ),
    );
  }
}


