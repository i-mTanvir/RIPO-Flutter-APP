import 'package:flutter/material.dart';
import 'package:ripo/admin_screens/admin_dashboard_screen.dart';
import 'package:ripo/core/auth_service.dart';
import 'package:ripo/customers_screens/customer_dashboard_screen.dart';
import 'package:ripo/providers_screens/provider_dashboard_screen.dart';

Widget screenForRole(AppUserRole role) {
  switch (role) {
    case AppUserRole.admin:
      return const AdminDashboardScreen();
    case AppUserRole.provider:
      return const ProviderDashboardScreen();
    case AppUserRole.customer:
      return const CustomerDashboardScreen();
  }
}
