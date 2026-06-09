import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../models/donation.dart';
import '../models/charity.dart';
import '../models/budget_goal.dart';

class AppProvider extends ChangeNotifier {
  List<Donation> donations = [];
  List<Charity> charities = [];
  double totalDonated = 0;
  Map<String, double> byCategory = {};
  List<Map<String, dynamic>> monthlyTotals = [];
  Map<int, double> byCharity = {};
  BudgetGoal? currentGoal;
  bool isLoading = false;

  String searchQuery = '';
  String selectedCategory = 'All';

  final now = DateTime.now();

  Future<void> loadAll() async {
    isLoading = true;
    notifyListeners();

    await Future.wait([
      _loadDonations(),
      _loadCharities(),
      _loadStats(),
    ]);

    isLoading = false;
    notifyListeners();
  }

  Future<void> _loadDonations() async {
    donations = await DBHelper.instance.getAllDonations(
      search: searchQuery.isEmpty ? null : searchQuery,
      category: selectedCategory == 'All' ? null : selectedCategory,
    );
  }

  Future<void> _loadCharities() async {
    charities = await DBHelper.instance.getAllCharities();
  }

  Future<void> _loadStats() async {
    totalDonated = await DBHelper.instance.getTotalDonated();
    byCategory = await DBHelper.instance.getTotalByCategory();
    monthlyTotals = await DBHelper.instance.getMonthlyTotals(12);
    byCharity = await DBHelper.instance.getTotalByCharity();
    currentGoal = await DBHelper.instance.getBudgetGoal(now.year, now.month);
  }

  void setSearch(String q) {
    searchQuery = q;
    _loadDonations().then((_) => notifyListeners());
  }

  void setCategory(String cat) {
    selectedCategory = cat;
    _loadDonations().then((_) => notifyListeners());
  }

  Future<void> addDonation(Donation d) async {
    await DBHelper.instance.insertDonation(d);
    await loadAll();
  }

  Future<void> updateDonation(Donation d) async {
    await DBHelper.instance.updateDonation(d);
    await loadAll();
  }

  Future<void> deleteDonation(int id) async {
    await DBHelper.instance.deleteDonation(id);
    await loadAll();
  }

  Future<void> addCharity(Charity c) async {
    await DBHelper.instance.insertCharity(c);
    await _loadCharities();
    notifyListeners();
  }

  Future<void> updateCharity(Charity c) async {
    await DBHelper.instance.updateCharity(c);
    await loadAll();
  }

  Future<void> deleteCharity(int id) async {
    await DBHelper.instance.deleteCharity(id);
    await loadAll();
  }

  Future<void> setGoal(double amount) async {
    final goal = BudgetGoal(year: now.year, month: now.month, goalAmount: amount);
    await DBHelper.instance.upsertBudgetGoal(goal);
    currentGoal = goal;
    notifyListeners();
  }

  double get thisMonthTotal {
    return donations
        .where((d) => d.date.year == now.year && d.date.month == now.month)
        .fold(0.0, (sum, d) => sum + d.amount);
  }
}