import 'package:flutter/material.dart';
import 'package:writer/shared/widgets/neumorphic_button.dart';
import 'package:writer/shared/widgets/neumorphic_checkbox.dart';
import 'package:writer/shared/widgets/neumorphic_dropdown.dart';
import 'package:writer/shared/widgets/neumorphic_radio.dart';
import 'package:writer/shared/widgets/neumorphic_slider.dart';
import 'package:writer/shared/widgets/neumorphic_switch.dart';
import 'package:writer/shared/widgets/neumorphic_textfield.dart';
import 'package:writer/theme/design_tokens.dart';
import 'package:writer/l10n/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.designSystemStyleGuide)),
      body: ListView(
        padding: const EdgeInsets.all(Spacing.xl),
        children: [
          _buildSection(
            'Typography',
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.headlineLarge,
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                Text(
                  l10n.headlineMedium,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                Text(
                  l10n.titleLarge,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Text(
                  l10n.bodyLarge,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                Text(
                  l10n.bodyMedium,
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
                  child: Text(l10n.primaryButton),
                ),
                const SizedBox(width: Spacing.m),
                NeumorphicButton(onPressed: null, child: Text(l10n.disabled)),
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
                Text(l10n.checkboxState(_checkboxValue)),
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
                    Text(l10n.option1),
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
                    Text(l10n.option2),
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
                Text(l10n.switchState(_switchValue)),
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
                Text(l10n.sliderValue(_sliderValue.toStringAsFixed(1))),
              ],
            ),
          ),
          _buildSection(
            'Input Fields',
            NeumorphicTextField(
              controller: _textController,
              hintText: l10n.enterTextHere,
            ),
          ),
          _buildSection(
            'Dropdowns',
            NeumorphicDropdown<String>(
              value: _dropdownValue,
              hint: Text(l10n.selectAnOption),
              items: [
                DropdownMenuItem(value: 'A', child: Text(l10n.optionA)),
                DropdownMenuItem(value: 'B', child: Text(l10n.optionB)),
                DropdownMenuItem(value: 'C', child: Text(l10n.optionC)),
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
