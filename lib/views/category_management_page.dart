import 'package:flutter/material.dart';
import '../models/category.dart';
import '../services/database_service.dart';
import 'icon_picker.dart';

class CategoryManagementPage extends StatefulWidget {
  const CategoryManagementPage({super.key});

  @override
  State<CategoryManagementPage> createState() => _CategoryManagementPageState();
}

class _CategoryManagementPageState extends State<CategoryManagementPage> {
  List<Category> _parentCategories = [];
  Map<int, List<Category>> _subCategories = {};
  Map<int, bool> _expandedState = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() => _isLoading = true);
    _parentCategories = await DatabaseService.getParentCategories();
    _subCategories.clear();
    
    for (final parent in _parentCategories) {
      _subCategories[parent.id] = await DatabaseService.getSubCategories(parent.id);
      if (!_expandedState.containsKey(parent.id)) {
        _expandedState[parent.id] = true;
      }
    }
    
    setState(() => _isLoading = false);
  }

  void _toggleExpand(int parentId) {
    setState(() {
      _expandedState[parentId] = !(_expandedState[parentId] ?? true);
    });
  }

  void _showAddCategoryDialog({Category? parentCategory}) {
    final TextEditingController nameController = TextEditingController();
    String selectedIcon = 'circle';
    final isSubCategory = parentCategory != null;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isSubCategory ? '添加子分类' : '添加分类'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: '分类名称',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                  showDialog(
                    context: context,
                    builder: (context) => IconPicker(
                      selectedIcon: selectedIcon,
                      onIconSelected: (icon) {
                        selectedIcon = icon;
                        Navigator.of(context).pop();
                        _showAddCategoryDialog(parentCategory: parentCategory);
                      },
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _getIconData(selectedIcon),
                        size: 32,
                      ),
                      const SizedBox(width: 16),
                      const Text('点击选择图标'),
                    ],
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('请输入分类名称')),
                  );
                  return;
                }

                final category = Category(
                  name: nameController.text.trim(),
                  icon: selectedIcon,
                  isDefault: false,
                  parentId: parentCategory?.id,
                );

                await DatabaseService.addCategory(category);
                await _loadCategories();
                Navigator.of(context).pop();

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${isSubCategory ? '子' : ''}分类添加成功')),
                );
              },
              child: const Text('确定'),
            ),
          ],
        );
      },
    );
  }

  void _showEditCategoryDialog(Category category) {
    final TextEditingController nameController = TextEditingController(text: category.name);
    String selectedIcon = category.icon;
    final isSubCategory = category.parentId != null;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isSubCategory ? '编辑子分类' : '编辑分类'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: '分类名称',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                  showDialog(
                    context: context,
                    builder: (context) => IconPicker(
                      selectedIcon: selectedIcon,
                      onIconSelected: (icon) {
                        selectedIcon = icon;
                        Navigator.of(context).pop();
                        _showEditCategoryDialog(category);
                      },
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _getIconData(selectedIcon),
                        size: 32,
                      ),
                      const SizedBox(width: 16),
                      const Text('点击选择图标'),
                    ],
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('请输入分类名称')),
                  );
                  return;
                }

                category.name = nameController.text.trim();
                category.icon = selectedIcon;

                await DatabaseService.updateCategory(category);
                await _loadCategories();
                Navigator.of(context).pop();

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${isSubCategory ? '子' : ''}分类编辑成功')),
                );
              },
              child: const Text('确定'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteCategoryDialog(Category category) {
    final isSubCategory = category.parentId != null;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('确认删除'),
          content: Text('确定要删除${isSubCategory ? '子' : ''}分类 "${category.name}" 吗？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('取消'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () async {
                await DatabaseService.deleteCategory(category.id);
                await _loadCategories();
                Navigator.of(context).pop();

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${isSubCategory ? '子' : ''}分类删除成功')),
                );
              },
              child: const Text('删除'),
            ),
          ],
        );
      },
    );
  }

  IconData _getIconData(String iconName) {
    final iconMap = {
      'restaurant': Icons.restaurant,
      'directions_car': Icons.directions_car,
      'shopping_cart': Icons.shopping_cart,
      'movie': Icons.movie,
      'local_hospital': Icons.local_hospital,
      'school': Icons.school,
      'attach_money': Icons.attach_money,
      'home': Icons.home,
      'work': Icons.work,
      'flight': Icons.flight,
      'train': Icons.train,
      'directions_bus': Icons.directions_bus,
      'directions_bike': Icons.directions_bike,
      'coffee': Icons.coffee,
      'fastfood': Icons.fastfood,
      'cake': Icons.cake,
      'local_bar': Icons.local_bar,
      'wine_bar': Icons.wine_bar,
      'music_note': Icons.music_note,
      'games': Icons.games,
      'book': Icons.book,
      'favorite': Icons.favorite,
      'star': Icons.star,
      'gift': Icons.card_giftcard,
      'wallet': Icons.wallet,
      'credit_card': Icons.credit_card,
      'account_balance': Icons.account_balance,
      'phone': Icons.phone,
      'laptop': Icons.laptop,
      'camera': Icons.camera,
      'photo': Icons.photo,
      'build': Icons.build,
      'local_shipping': Icons.local_shipping,
      'package': Icons.inbox,
      'mail': Icons.mail,
      'cloud': Icons.cloud,
      'wb_sunny': Icons.wb_sunny,
      'moon': Icons.nightlight_round,
      'umbrella': Icons.umbrella,
      'ac_unit': Icons.ac_unit,
      'droplet': Icons.water_drop,
      'leaf': Icons.eco,
      'flower': Icons.local_florist,
      'accessibility_new': Icons.accessibility_new,
      'pets': Icons.pets,
      'bug_report': Icons.bug_report,
      'sparkles': Icons.star,
      'flame': Icons.fireplace,
      'zap': Icons.flash_on,
      'shield': Icons.shield,
      'lock': Icons.lock,
      'lock_open': Icons.lock_open,
      'vpn_key': Icons.vpn_key,
      'notifications': Icons.notifications,
      'error': Icons.error,
      'check': Icons.check,
      'close': Icons.close,
      'add': Icons.add,
      'remove': Icons.remove,
      'refresh': Icons.refresh,
      'settings': Icons.settings,
      'search': Icons.search,
      'folder': Icons.folder,
      'file_copy': Icons.file_copy,
      'download': Icons.download,
      'upload': Icons.upload,
      'save': Icons.save,
      'delete': Icons.delete,
      'edit': Icons.edit,
      'content_copy': Icons.content_copy,
      'undo': Icons.undo,
      'redo': Icons.redo,
      'link': Icons.link,
      'tag': Icons.tag,
      'bookmark': Icons.bookmark,
      'history': Icons.history,
      'clock': Icons.access_time,
      'calendar_today': Icons.calendar_today,
      'map': Icons.map,
      'navigation': Icons.navigation,
      'globe': Icons.public,
      'group': Icons.group,
      'person': Icons.person,
      'face': Icons.face,
      'visibility': Icons.visibility,
      'visibility_off': Icons.visibility_off,
      'activity': Icons.timeline,
      'pulse': Icons.favorite,
      'fitness_center': Icons.fitness_center,
      'run': Icons.directions_run,
      'walk': Icons.directions_walk,
      'directions_boat': Icons.directions_boat,
      'rocket': Icons.rocket,
      'cpu': Icons.memory,
      'battery_full': Icons.battery_full,
      'usb': Icons.usb,
      'bluetooth': Icons.bluetooth,
      'wifi': Icons.wifi,
      'speaker': Icons.speaker,
      'mic': Icons.mic,
      'pause': Icons.pause,
      'play_arrow': Icons.play_arrow,
      'stop': Icons.stop,
      'tv': Icons.tv,
      'ticket': Icons.event,
      'popcorn': Icons.theaters,
      'crown': Icons.emoji_events,
      'trophy': Icons.emoji_events,
      'medal': Icons.military_tech,
      'circle': Icons.circle,
    };
    return iconMap[iconName] ?? Icons.circle;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('分类管理'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView.builder(
                itemCount: _parentCategories.length,
                itemBuilder: (context, index) {
                  final parent = _parentCategories[index];
                  final subs = _subCategories[parent.id] ?? [];
                  final isExpanded = _expandedState[parent.id] ?? true;

                  return Column(
                    children: [
                      Card(
                        child: ListTile(
                          leading: Icon(
                            _getIconData(parent.icon),
                            size: 24,
                          ),
                          title: Row(
                            children: [
                              Text(parent.name),
                              if (parent.isDefault)
                                const Padding(
                                  padding: EdgeInsets.only(left: 8),
                                  child: Text(
                                    '(默认)',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: () => _showAddCategoryDialog(parentCategory: parent),
                                icon: const Icon(Icons.add_circle_outline),
                                tooltip: '添加子分类',
                              ),
                              if (!parent.isDefault)
                                IconButton(
                                  onPressed: () => _showEditCategoryDialog(parent),
                                  icon: const Icon(Icons.edit),
                                  tooltip: '编辑',
                                ),
                              if (!parent.isDefault)
                                IconButton(
                                  onPressed: () => _showDeleteCategoryDialog(parent),
                                  icon: const Icon(Icons.delete),
                                  tooltip: '删除',
                                ),
                              IconButton(
                                onPressed: () => _toggleExpand(parent.id),
                                icon: Icon(
                                  isExpanded
                                      ? Icons.expand_less
                                      : Icons.expand_more,
                                ),
                              ),
                            ],
                          ),
                          onTap: () => _toggleExpand(parent.id),
                        ),
                      ),
                      if (isExpanded && subs.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(left: 48),
                          child: Column(
                            children: subs.map((sub) {
                              return Card(
                                elevation: 0.5,
                                child: ListTile(
                                  leading: Icon(
                                    _getIconData(sub.icon),
                                    size: 20,
                                  ),
                                  title: Text(sub.name),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        onPressed: () => _showEditCategoryDialog(sub),
                                        icon: const Icon(Icons.edit),
                                        tooltip: '编辑',
                                      ),
                                      IconButton(
                                        onPressed: () => _showDeleteCategoryDialog(sub),
                                        icon: const Icon(Icons.delete),
                                        tooltip: '删除',
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      const SizedBox(height: 8),
                    ],
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddCategoryDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
