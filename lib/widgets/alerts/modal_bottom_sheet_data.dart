class SidemenuListBottomSheetData{
  String title;
  String? subTitle;
  String? icon;
  bool isChecked;
  Function() onPressed;

  SidemenuListBottomSheetData({
    required this.title,
    this.subTitle,
    this.icon,
    required this.isChecked,
    required this.onPressed
  });
}
