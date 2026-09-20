import 'package:app_movil_sistema/core/theme/app_colors.dart';
import 'package:flutter/material.dart';


class XsMultiFilter<T> extends StatefulWidget {

  final List<T> items;
  final String Function(T item) labelBuilder;
  final int Function(T item) valueBuilder;
  final ValueChanged<List<int>>? onChanged;

  const XsMultiFilter({
    super.key,
    required this.items,
    required this.labelBuilder,
    required this.valueBuilder,
    this.onChanged,
  });


  @override
  State<XsMultiFilter<T>> createState() => XsMultiFilterState<T>();

}



class XsMultiFilterState<T> extends State<XsMultiFilter<T>> {

  final List<int> _selected = [];

  void clear(){

    setState(() {
      _selected.clear();
    });

    widget.onChanged?.call([],);

  }

  void _toggle(T item){
    final value = widget.valueBuilder(item);

    setState(() {
      if(_selected.contains(value)){
        _selected.remove(value);
      }else{
        _selected.add(value);
      }

    });

    widget.onChanged?.call(List<int>.from(_selected),);

  }


  @override
  Widget build(BuildContext context){

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: widget.items.length,
        separatorBuilder: (_,__) =>
        const SizedBox(width: 8,),

        itemBuilder: (context,index){
          final item = widget.items[index];
          final value = widget.valueBuilder(item);
          final selected = _selected.contains(value);

          return GestureDetector(

            onTap: (){
              _toggle(item);
            },


            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200,),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8,),
              decoration: BoxDecoration(
                color: selected ? AppColors.primary : isDark ? AppColors.dark : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: selected ? AppColors.primary : Colors.grey.withValues(alpha: .25,),
                ),

                boxShadow: selected ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: .25,),
                    blurRadius: 8,
                    offset: const Offset(0, 3,),
                  ),
                ] : null,

              ),

              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if(selected)
                    const Padding(
                      padding: EdgeInsets.only(right: 6,),
                      child: Icon(
                        Icons.check_circle,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),

                  Text(
                    widget.labelBuilder(item),
                    style:
                    TextStyle(
                      fontSize: 13,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                      color: selected ? Colors.white : isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}