import 'package:flutter/material.dart';

class SummaryMainContent extends StatelessWidget {
  const SummaryMainContent({
    super.key,
    required this.formKey,
    required this.novelHeader,
    required this.tabController,
    required this.tabs,
    required this.tabViews,
    required this.footer,
  });

  final GlobalKey<FormState> formKey;
  final Widget novelHeader;
  final TabController tabController;
  final List<Tab> tabs;
  final List<Widget> tabViews;
  final Widget footer;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          novelHeader,
          const SizedBox(height: 16),
          TabBar(controller: tabController, tabs: tabs),
          const SizedBox(height: 8),
          Expanded(
            child: TabBarView(controller: tabController, children: tabViews),
          ),
          footer,
        ],
      ),
    );
  }
}
