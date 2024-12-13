import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/inventory_view_model.dart';

class InventoryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => InventoryViewModel(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Inventory'),
          actions: [
            Consumer<InventoryViewModel>(
              builder: (context, viewModel, _) => TextButton.icon(
                icon: Icon(viewModel.isAscending
                    ? Icons.arrow_upward
                    : Icons.arrow_downward),
                label: const Text('QTY'),
                onPressed: viewModel.sortItems,
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                decoration: InputDecoration(
                  labelText: 'Search',
                  prefixIcon: const Icon(Icons.search),
                  border: const OutlineInputBorder(),
                ),
                onChanged: (value) =>
                    context.read<InventoryViewModel>().filterItems(value),
              ),
            ),
            Expanded(
              child: Consumer<InventoryViewModel>(
                builder: (context, viewModel, _) {
                  if (viewModel.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return RefreshIndicator(
                    onRefresh: () async {
                      viewModel.isLoading = true;
                      await viewModel.fetchData();                    },
                    child: ListView.builder(
                      itemCount: viewModel.filteredItems.length,
                      itemBuilder: (context, index) {
                        final item = viewModel.filteredItems[index];
                        return Container(
                          color: item.qty < 5 ? Colors.red[100] : Colors.white,
                          child: ListTile(
                            title: Text(item.name),
                            subtitle: Text('Quantity: ${item.qty}'),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
