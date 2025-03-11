import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../models/user_profile.dart';
import '../../services/database_service.dart';
import '../../services/auth_service.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  _UserManagementScreenState createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final DatabaseService _databaseService = DatabaseService();
  final AuthService _authService = AuthService();

  List<UserProfile> _users = [];
  List<UserProfile> _filteredUsers = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  // Filtering and Sorting
  String _selectedMembershipFilter = 'All';
  String _sortBy = 'Name';
  bool _isAscending = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    try {
      // Fetch all users
      final users = await _databaseService.getAllUsers();
      setState(() {
        _users = users;
        _filteredUsers = users;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar('Failed to load users: $e');
    }
  }

  void _filterUsers(String query) {
    setState(() {
      _filteredUsers = _users.where((user) {
        final nameMatch = user.displayName.toLowerCase().contains(query.toLowerCase());
        final emailMatch = user.email.toLowerCase().contains(query.toLowerCase());
        final membershipMatch = _selectedMembershipFilter == 'All' ||
            user.membershipStatus == _selectedMembershipFilter;

        return (nameMatch || emailMatch) && membershipMatch;
      }).toList();

      _sortUsers();
    });
  }

  void _sortUsers() {
    setState(() {
      switch (_sortBy) {
        case 'Name':
          _filteredUsers.sort((a, b) => _isAscending
              ? a.displayName.compareTo(b.displayName)
              : b.displayName.compareTo(a.displayName));
          break;
        case 'Email':
          _filteredUsers.sort((a, b) => _isAscending
              ? a.email.compareTo(b.email)
              : b.email.compareTo(a.email));
          break;
        case 'Membership':
          _filteredUsers.sort((a, b) => _isAscending
              ? a.membershipStatus.compareTo(b.membershipStatus)
              : b.membershipStatus.compareTo(a.membershipStatus));
          break;
      }
    });
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterBottomSheet,
          ),
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: _showSortBottomSheet,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildUserList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddUserBottomSheet,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search users...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              _searchController.clear();
              _filterUsers('');
            },
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onChanged: _filterUsers,
      ),
    );
  }

  Widget _buildUserList() {
    if (_filteredUsers.isEmpty) {
      return const Center(
        child: Text('No users found'),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadUsers,
      child: AnimationLimiter(
        child: ListView.builder(
          itemCount: _filteredUsers.length,
          itemBuilder: (context, index) {
            final user = _filteredUsers[index];
            return AnimationConfiguration.staggeredList(
              position: index,
              duration: const Duration(milliseconds: 375),
              child: SlideAnimation(
                verticalOffset: 50.0,
                child: FadeInAnimation(
                  child: Slidable(
                    key: Key(user.uid),
                    startActionPane: ActionPane(
                      motion: const ScrollMotion(),
                      children: [
                        SlidableAction(
                          onPressed: (context) => _editUser(user),
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          icon: Icons.edit,
                          label: 'Edit',
                        ),
                      ],
                    ),
                    endActionPane: ActionPane(
                      motion: const ScrollMotion(),
                      children: [
                        SlidableAction(
                          onPressed: (context) => _deleteUser(user),
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          icon: Icons.delete,
                          label: 'Delete',
                        ),
                      ],
                    ),
                    child: _buildUserListTile(user),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildUserListTile(UserProfile user) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: user.photoURL != null
            ? NetworkImage(user.photoURL!)
            : null,
        child: user.photoURL == null ? const Icon(Icons.person) : null,
      ),
      title: Text(user.displayName),
      subtitle: Text(user.email),
      trailing: _buildMembershipChip(user.membershipStatus),
    );
  }

  Widget _buildMembershipChip(String status) {
    Color chipColor;
    switch (status.toLowerCase()) {
      case 'active':
        chipColor = Colors.green;
        break;
      case 'pending':
        chipColor = Colors.orange;
        break;
      case 'inactive':
        chipColor = Colors.red;
        break;
      default:
        chipColor = Colors.grey;
    }

    return Chip(
      label: Text(status),
      backgroundColor: chipColor.withOpacity(0.1),
      labelStyle: TextStyle(color: chipColor),
    );
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Filter Users',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedMembershipFilter,
                    decoration: const InputDecoration(
                      labelText: 'Membership Status',
                      border: OutlineInputBorder(),
                    ),
                    items: ['All', 'Active', 'Pending', 'Inactive']
                        .map((status) => DropdownMenuItem(
                      value: status,
                      child: Text(status),
                    ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        _selectedMembershipFilter = value;
                        _filterUsers(_searchController.text);
                      }
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showSortBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Sort Users',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _sortBy,
                    decoration: const InputDecoration(
                      labelText: 'Sort By',
                      border: OutlineInputBorder(),
                    ),
                    items: ['Name', 'Email', 'Membership']
                        .map((sort) => DropdownMenuItem(
                      value: sort,
                      child: Text(sort),
                    ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        _sortBy = value;
                        _sortUsers();
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: Text(_isAscending ? 'Ascending' : 'Descending'),
                    value: _isAscending,
                    onChanged: (value) {
                      _isAscending = value;
                      _sortUsers();
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showAddUserBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Add New User',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Membership Status',
                  border: OutlineInputBorder(),
                ),
                items: ['Active', 'Pending', 'Inactive']
                    .map((status) => DropdownMenuItem(
                  value: status,
                  child: Text(status),
                ))
                    .toList(),
                onChanged: (value) {
                  // Handle membership status selection
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  // Implement user creation logic
                  Navigator.pop(context);
                  _loadUsers(); // Refresh the user list
                },
                child: const Text('Create User'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _editUser(UserProfile user) {
    // Implement user editing logic
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditUserScreen(user: user),
      ),
    ).then((_) => _loadUsers());
  }

  void _deleteUser(UserProfile user) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete User'),
          content: Text('Are you sure you want to delete ${user.displayName}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await _authService.deleteUser(user.uid);
                  Navigator.pop(context);
                  _loadUsers();
                } catch (e) {
                  _showErrorSnackBar('Failed to delete user: $e');
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}

// Separate screen for editing user details
class EditUserScreen extends StatefulWidget {
  final UserProfile user;

  const EditUserScreen({super.key, required this.user});

  @override
  _EditUserScreenState createState() => _EditUserScreenState();
}

class _EditUserScreenState extends State<EditUserScreen> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  String _membershipStatus = '';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.displayName);
    _emailController = TextEditingController(text: widget.user.email);
    _membershipStatus = widget.user.membershipStatus;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit User'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _membershipStatus,
              decoration: const InputDecoration(
                labelText: 'Membership Status',
                border: OutlineInputBorder(),
              ),
              items: ['Active', 'Pending', 'Inactive']
                  .map((status) => DropdownMenuItem(
                value: status,
                child: Text(status),
              ))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _membershipStatus = value;
                  });
                }
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saveUserChanges,
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }

  void _saveUserChanges() async {
    try {
      final DatabaseService databaseService = DatabaseService();
      await databaseService.updateUserProfile(widget.user.uid, {
        'displayName': _nameController.text,
        'email': _emailController.text,
        'membershipStatus': _membershipStatus,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update user: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }
}