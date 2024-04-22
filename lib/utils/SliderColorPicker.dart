import 'package:flutter/material.dart';

class SliderColorPicker extends StatefulWidget {
  final double initialSliderValue;
  final Color initialSelectedColor;
  final ValueChanged<Color> onColorSelected;
  final ValueChanged<double> onSliderValueChanged;

  SliderColorPicker({
    required this.initialSliderValue,
    required this.initialSelectedColor,
    required this.onColorSelected,
    required this.onSliderValueChanged,
    Key? key,
  }) : super(key: key);

  @override
  _SliderColorPickerState createState() => _SliderColorPickerState();
}


class _SliderColorPickerState extends State<SliderColorPicker> {
  late double _sliderValue;
  late Color _selectedColor;

  @override
  void initState() {
    super.initState();
    _sliderValue = widget.initialSliderValue;
    _selectedColor = widget.initialSelectedColor;
  }

  void _updateColor(double value) {
    int index = (value * (timelineColors.length - 1)).round();
    setState(() {
      _sliderValue = value;
      _selectedColor = timelineColors[index];
    });
    widget.onColorSelected(_selectedColor);
    widget.onSliderValueChanged(value);
  }


  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      backgroundColor: Colors.transparent,
      contentPadding: EdgeInsets.zero,
      elevation: 0,
      children: [
        Container(
          width: 300,
          height: 10,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: LinearGradient(
              colors: timelineColors,
              stops: timelineStops,
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
          child: Slider(
            value: _sliderValue,
            onChanged: _updateColor,
            min: 0,
            max: 1,
            activeColor: Colors.transparent,
            inactiveColor: Colors.transparent,
          ),
        ),
      ],
    );
  }
}

List<Color> timelineColors = [
  Colors.red,
  Colors.blue,
  Colors.green,
  Colors.yellow,
  Colors.purple,
];

List<double> timelineStops = [
  0.0,
  0.25,
  0.5,
  0.75,
  1.0,
];
