import 'package:flutter/material.dart';
import 'package:gym_app/view_model/course_list_view_model.dart';
import 'package:gym_app/viewes/course_view/course_info_view.dart';

class CourseListView extends StatefulWidget {
  @override
  _CourseListViewState createState() => _CourseListViewState();
}

class _CourseListViewState extends State<CourseListView> {
  final CourseListViewModel _viewModel = CourseListViewModel();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    await _viewModel.fetchCourses();
    setState(() {}); // Refresh the UI
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Courses',
            style: TextStyle(
              color: Colors.deepPurple,
              fontWeight: FontWeight.w700,
            ),
          ),
          backgroundColor: Colors.white,
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(kToolbarHeight),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search courses...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15.0),
                    borderSide: BorderSide.none,
                  ),
                  fillColor: Colors.grey[200],
                  filled: true,
                ),
                onChanged: (value) {
                  setState(() {
                    _viewModel.filterCourses(value);
                  });
                },
              ),
            ),
          ),
        ),
        body: _viewModel.courses.isEmpty
            ? Center(child: Text("No course found"))
            : ListView.builder(
          itemCount: _viewModel.courses.length,
          itemBuilder: (context, index) {
            final course = _viewModel.courses[index];
            return FutureBuilder(
              future: Future.wait([
                _viewModel.getInstructorName(course.instructorId),
                _viewModel.getMemberName(course.memberId),
              ]),
              builder: (context, AsyncSnapshot<List<String>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                final instructorName = snapshot.data![0];
                final memberName = snapshot.data![1];
                return Card(
                  margin: EdgeInsets.all(8.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  elevation: 5,
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text(
                        (index + 1).toString(),
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      backgroundColor: Colors.blueAccent,
                    ),
                    title: Text(
                      course.name,
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Member: $memberName',
                                  style: TextStyle(fontSize: 14)),
                              Text('Instructor: $instructorName',
                                  style: TextStyle(fontSize: 14)),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Duration: ${course.duration} days',
                                  style: TextStyle(fontSize: 14)),
                              Text('Level: ${course.level}',
                                  style: TextStyle(
                                      fontSize: 14,
                                      color: Color.fromARGB(255, 22, 159, 146))),
                            ],
                          ),
                        ],
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(width: 12.0),
                        Icon(Icons.arrow_forward_ios, size: 16),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                CourseInfoView(course: course)),
                      );
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
