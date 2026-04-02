// lib/features/profile/screens/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/profile_service.dart';
import '../model/user_profile.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ProfileService _service = ProfileService();

  UserProfile? _profile;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      setState(() {
        _loading = true;
        _error = null;
      });

      final data = await _service.getProfile();

      setState(() => _profile = data);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_error!),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: _load, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }

    final p = _profile!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _load,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: CircleAvatar(
              radius: 40,
              backgroundImage:
                  p.anhDaiDienUrl != null ? NetworkImage(p.anhDaiDienUrl!) : null,
              child: p.anhDaiDienUrl == null
                  ? const Icon(Icons.person)
                  : null,
            ),
          ),
          const SizedBox(height: 16),

          Text('Name: ${p.fullName}'),
          Text('Username: ${p.username}'),
          Text('Email: ${p.email}'),
          Text('Phone: ${p.phoneNumber ?? ''}'),
          Text('Address: ${p.diaChi ?? ''}'),
          Text('Gender: ${p.gioiTinhName ?? ''}'),
          Text('Roles: ${p.roles.join(', ')}'),

          const SizedBox(height: 24),

          ElevatedButton(
            onPressed: () {
              context.push('/profile/change-password');
            },
            child: const Text('Change Password'),
          ),

          ElevatedButton(
            onPressed: () {
              context.push('/profile/change-avatar');
            },
            child: const Text('Change Avatar'),
          ),
        ],
      ),
    );
  }
}