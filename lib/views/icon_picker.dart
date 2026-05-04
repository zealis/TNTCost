import 'package:flutter/material.dart';

enum IconStyle { fluent3d, fluentMono }

class IconPicker extends StatefulWidget {
  final String? selectedIcon;
  final ValueChanged<String> onIconSelected;

  const IconPicker({
    super.key,
    this.selectedIcon,
    required this.onIconSelected,
  });

  @override
  State<IconPicker> createState() => _IconPickerState();
}

class _IconPickerState extends State<IconPicker> {
  IconStyle _currentStyle = IconStyle.fluent3d;

  final List<String> _iconNames = [
    'restaurant',
    'directions_car',
    'shopping_cart',
    'movie',
    'local_hospital',
    'school',
    'attach_money',
    'home',
    'work',
    'flight',
    'train',
    'directions_bus',
    'directions_bike',
    'coffee',
    'fastfood',
    'cake',
    'local_bar',
    'wine_bar',
    'music_note',
    'games',
    'book',
    'favorite',
    'star',
    'gift',
    'wallet',
    'credit_card',
    'account_balance',
    'phone',
    'laptop',
    'camera',
    'photo',
    'build',
    'local_shipping',
    'package',
    'mail',
    'cloud',
    'wb_sunny',
    'moon',
    'umbrella',
    'ac_unit',
    'droplet',
    'leaf',
    'flower',
    'accessibility_new',
    'pets',
    'bug_report',
    'sparkles',
    'flame',
    'zap',
    'shield',
    'lock',
    'lock_open',
    'vpn_key',
    'notifications',
    'error',
    'check',
    'close',
    'add',
    'remove',
    'refresh',
    'settings',
    'search',
    'folder',
    'file_copy',
    'download',
    'upload',
    'save',
    'delete',
    'edit',
    'content_copy',
    'undo',
    'redo',
    'link',
    'tag',
    'bookmark',
    'history',
    'clock',
    'calendar_today',
    'map',
    'navigation',
    'globe',
    'group',
    'person',
    'face',
    'visibility',
    'visibility_off',
    'activity',
    'pulse',
    'fitness_center',
    'run',
    'walk',
    'directions_boat',
    'rocket',
    'cpu',
    'battery_full',
    'usb',
    'bluetooth',
    'wifi',
    'speaker',
    'mic',
    'pause',
    'play_arrow',
    'stop',
    'tv',
    'ticket',
    'popcorn',
    'crown',
    'trophy',
    'medal',
  ];

  IconData _getIconData(String name) {
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
    };
    return iconMap[name] ?? Icons.circle;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('选择图标'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () => setState(() => _currentStyle = IconStyle.fluent3d),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _currentStyle == IconStyle.fluent3d
                      ? Theme.of(context).primaryColor
                      : null,
                ),
                child: const Text('Fluent 3D'),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: () => setState(() => _currentStyle = IconStyle.fluentMono),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _currentStyle == IconStyle.fluentMono
                      ? Theme.of(context).primaryColor
                      : null,
                ),
                child: const Text('Fluent Mono'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: 400,
            height: 300,
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 8,
                childAspectRatio: 1,
              ),
              itemCount: _iconNames.length,
              itemBuilder: (context, index) {
                final iconName = _iconNames[index];
                final isSelected = widget.selectedIcon == iconName;
                final iconData = _getIconData(iconName);
                
                return GestureDetector(
                  onTap: () => widget.onIconSelected(iconName),
                  child: Container(
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Theme.of(context).primaryColor.withOpacity(0.2)
                          : null,
                      borderRadius: BorderRadius.circular(8),
                      border: isSelected
                          ? Border.all(
                              color: Theme.of(context).primaryColor,
                              width: 2,
                            )
                          : null,
                    ),
                    child: Center(
                      child: Icon(
                        iconData,
                        size: 24,
                        color: isSelected
                            ? Theme.of(context).primaryColor
                            : null,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
      ],
    );
  }
}
