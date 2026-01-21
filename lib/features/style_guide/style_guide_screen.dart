import 'package:flutter/material.dart';
import 'package:writer/shared/widgets/neumorphic_button.dart';
import 'package:writer/shared/widgets/neumorphic_checkbox.dart';
import 'package:writer/shared/widgets/neumorphic_dropdown.dart';
import 'package:writer/shared/widgets/neumorphic_radio.dart';
import 'package:writer/shared/widgets/neumorphic_slider.dart';
import 'package:writer/shared/widgets/neumorphic_switch.dart';
import 'package:writer/shared/widgets/neumorphic_textfield.dart';
import 'package:writer/theme/design_tokens.dart';

class StyleGuideScreen extends StatefulWidget {
  const StyleGuideScreen({super.key});

  @override
  State<StyleGuideScreen> createState() => _StyleGuideScreenState();
}

class _StyleGuideScreenState extends State<StyleGuideScreen> {
  bool _checkboxValue = false;
  int _radioValue = 0;
  bool _switchValue = false;
  double _sliderValue = 50.0;
  String? _dropdownValue;
  final TextEditingController _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Design System Style Guide')),
      body: ListView(
        padding: const EdgeInsets.all(Spacing.xl),
        children: [
          _buildSection(
            'Typography',
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Headline Large',
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                Text(
                  'Headline Medium',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                Text(
                  'Title Large',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Text(
                  'Body Large',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                Text(
                  'Body Medium',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          _buildSection(
            'Buttons',
            Row(
              children: [
                NeumorphicButton(
                  onPressed: () {},
                  child: const Text('Primary Button'),
                ),
                const SizedBox(width: Spacing.m),
                const NeumorphicButton(
                  onPressed: null,
                  child: Text('Disabled'),
                ),
              ],
            ),
          ),
          _buildSection(
            'Checkboxes (Standardized)',
            Row(
              children: [
                NeumorphicCheckbox(
                  value: _checkboxValue,
                  onChanged: (v) => setState(() => _checkboxValue = v ?? false),
                ),
                const SizedBox(width: Spacing.m),
                Text('Checkbox State: $_checkboxValue'),
              ],
            ),
          ),
          _buildSection(
            'Radio Buttons',
            Column(
              children: [
                Row(
                  children: [
                    NeumorphicRadio<int>(
                      value: 0,
                      groupValue: _radioValue,
                      onChanged: (v) => setState(() => _radioValue = v!),
                    ),
                    const SizedBox(width: Spacing.s),
                    const Text('Option 1'),
                  ],
                ),
                const SizedBox(height: Spacing.s),
                Row(
                  children: [
                    NeumorphicRadio<int>(
                      value: 1,
                      groupValue: _radioValue,
                      onChanged: (v) => setState(() => _radioValue = v!),
                    ),
                    const SizedBox(width: Spacing.s),
                    const Text('Option 2'),
                  ],
                ),
              ],
            ),
          ),
          _buildSection(
            'Toggles / Switches',
            Row(
              children: [
                NeumorphicSwitch(
                  value: _switchValue,
                  onChanged: (v) => setState(() => _switchValue = v),
                ),
                const SizedBox(width: Spacing.m),
                Text('Switch State: $_switchValue'),
              ],
            ),
          ),
          _buildSection(
            'Sliders',
            Column(
              children: [
                NeumorphicSlider(
                  value: _sliderValue,
                  min: 0,
                  max: 100,
                  onChanged: (v) => setState(() => _sliderValue = v),
                ),
                Text('Value: ${_sliderValue.toStringAsFixed(1)}'),
              ],
            ),
          ),
          _buildSection(
            'Input Fields',
            NeumorphicTextField(
              controller: _textController,
              hintText: 'Enter text here...',
            ),
          ),
          _buildSection(
            'Dropdowns',
            NeumorphicDropdown<String>(
              value: _dropdownValue,
              hint: const Text('Select an option'),
              items: const [
                DropdownMenuItem(value: 'A', child: Text('Option A')),
                DropdownMenuItem(value: 'B', child: Text('Option B')),
                DropdownMenuItem(value: 'C', child: Text('Option C')),
              ],
              onChanged: (v) => setState(() => _dropdownValue = v),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, Widget content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Spacing.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: Spacing.m),
          content,
          const Divider(height: Spacing.xl),
        ],
      ),
    );
  }
}
