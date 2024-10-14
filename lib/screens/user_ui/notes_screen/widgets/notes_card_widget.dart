import 'package:asthmaapp/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';

class NoteCardWidget extends StatelessWidget {
  final Map<String, dynamic> note;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final double screenRatio;

  const NoteCardWidget({
    super.key,
    required this.note,
    required this.onEdit,
    required this.onDelete,
    required this.screenRatio,
  });

  @override
  Widget build(BuildContext context) {
    return Slidable(
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        children: [
          // SlidableAction(
          //   onPressed: (context) => onDelete(),
          //   icon: Icons.delete,
          //   label: 'Delete',
          //   backgroundColor: Colors.red,
          //   foregroundColor: Colors.white,
          // ),
          SlidableAction(
            onPressed: (context) => onEdit(),
            icon: Icons.edit,
            label: 'Edit',
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
        ],
      ),
      child: Card(
        color: Colors.white,
        child: ListTile(
          leading: note['feelRating'] == "Happy"
              ? const Icon(
                  Icons.sentiment_satisfied_sharp,
                  color: Colors.green,
                )
              : note['feelRating'] == "Average"
                  ? const Icon(
                      Icons.sentiment_neutral,
                      color: Colors.amber,
                    )
                  : const Icon(
                      Icons.sentiment_dissatisfied,
                      color: Colors.red,
                    ),
          title: Text(
            note['title'],
            style: TextStyle(
              color: AppColors.primaryBlue,
              fontSize: screenRatio * 7,
              fontWeight: FontWeight.normal,
              fontFamily: 'Roboto',
            ),
          ),
          subtitle: Text(
            note['description'],
            style: TextStyle(
              color: AppColors.primaryBlue,
              fontSize: screenRatio * 5,
              fontWeight: FontWeight.normal,
              fontFamily: 'Roboto',
            ),
          ),
          trailing: Text(
            DateFormat('dd/MM/yyyy').format(DateTime.parse(note['createdAt'])),
            style: TextStyle(
              color: AppColors.primaryBlue,
              fontSize: screenRatio * 5,
              fontWeight: FontWeight.normal,
              fontFamily: 'Roboto',
            ),
          ),
        ),
      ),
    );
  }
}
