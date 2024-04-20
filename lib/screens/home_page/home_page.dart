import 'dart:convert';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:notes/constants/sp_keys.dart';
import 'package:notes/screens/home_page/alert_dialogbox.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/user_model.dart';
import 'bottom_sheet.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  String name = 'No Data';
  List<String> getTitleList = [];
  List<String> getDescList = [];
  List<int> getIdList = [];
  List<bool> getStatusList = [];

  int delIndex = 0;
  int editIndex = 0;
  bool isEdit = false;
  bool status = false;
  ToDoModel toDoModel = ToDoModel();
  int editId = 0;

  @override
  void initState() {
    super.initState();
    getName();
  }

  _showDialog(BuildContext context, int index) {
    continueCallBack() {
      delIndex = index;
      setState(() {
        delName();
      });
      delName();
      Navigator.of(context).pop();
    }

    BlurryDialog alert =
    BlurryDialog("Delete", "Are you sure you want to delete this note?", continueCallBack);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 100,
              sigmaY: 100,
            ),
            child: Container(
              color: Colors.transparent,
            ),
          ),
        ),
        automaticallyImplyLeading: true,
        backgroundColor: Colors.transparent,
        elevation: 1,
        title: const Text(
          'Notes',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        // shadowColor: Colors.blue,
        actions: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: IconButton(
              onPressed: () {
                Navigator.pushNamed(context, '/dashboard');
              },
              icon: const Icon(CupertinoIcons.person, color: Colors.white),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
        child: Center(
            child: getTitleList.isNotEmpty
                ? ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: getTitleList.length,
                    itemBuilder: (context, index) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Checkbox(
                            value: getStatusList[index],
                            side: const BorderSide(
                                color: Colors.white, width: 1.5),
                            checkColor: Colors.black,
                            activeColor: Colors.white,
                            onChanged: (c) {
                              setState(() {
                                getStatusList[index] = !getStatusList[index];
                              });
                              changeStatus(index);
                            },
                          ),
                          Flexible(
                            child: GestureDetector(
                              onTap: () async {
                                await getBottomModelSheet(getTitleList[index],
                                    getDescList[index], getIdList[index], true);
                                isEdit = true;
                                editIndex = index;
                              },
                              child: Card(
                                color: Colors.black12,
                                shadowColor: getStatusList[index]
                                    ? Colors.grey
                                    : Colors.blue,
                                elevation: 5,
                                child: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Flexible(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              getTitleList[index],
                                              overflow: TextOverflow.visible,
                                              style: TextStyle(
                                                  color: getStatusList[index]
                                                      ? Colors.grey
                                                      : Colors.white,
                                                  decoration:
                                                      getStatusList[index]
                                                          ? TextDecoration
                                                              .lineThrough
                                                          : TextDecoration.none,
                                                  fontSize: 21,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Text(
                                              getDescList[index],
                                              overflow: TextOverflow.visible,
                                              style: TextStyle(
                                                color: getStatusList[index]
                                                    ? Colors.grey
                                                    : Colors.white,
                                                decoration: getStatusList[index]
                                                    ? TextDecoration.lineThroughgit init
                                                    : TextDecoration.none,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(5),
                                        child: GestureDetector(
                                          onTap: () {
                                            _showDialog(context, index);
                                          },
                                          child: const Icon(
                                            Icons.delete_forever,
                                            color: Colors.red,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  )
                : const Center(
                    child: Text(
                      'No Data',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  )),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await getBottomModelSheet(null, null, null, false);
        },
        backgroundColor: Colors.blue.withAlpha(200),
        splashColor: Colors.blue.withAlpha(200),
        elevation: 25,
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }

  //#region -- Methods
  Future<void> getBottomModelSheet(String? titleValue, String? descValue,
      int? editId, bool isEditBool) async {
    showModalBottomSheet(
        // barrierColor: Colors.transparent,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topRight: Radius.circular(30), topLeft: Radius.circular(30)),
        ),
        context: context,
        builder: (context) {
          return BackdropFilter(
            filter: ImageFilter.blur(sigmaY: 10, sigmaX: 10),
            child: Padding(
                padding: MediaQuery.of(context).viewInsets,
                child: AddSheet(titleValue, descValue, editId)),
          );
        }).then((value) {
      if (value ?? false) {
        isEditBool ? editName() : getName();
      }
    });
  }

  Future<void> changeStatus(int index) async {
    final sp = await SharedPreferences.getInstance();
    final jsonString = sp.getString(AppKeys.json);
    final json = jsonDecode(jsonString!);
    List<dynamic> userDataList = json[sp.getString(AppKeys.currentUserKey)];
    List<ToDoModel> dataList =
        userDataList.map((e) => ToDoModel.fromJson((e))).toList();
    if (getStatusList[index] == true) {
      dataList[index].status = true;
    } else {
      dataList[index].status = false;
    }
    sp.setString(AppKeys.editData, jsonEncode(dataList[index]));
    json[sp.getString(AppKeys.currentUserKey)] = dataList;
    sp.setString(AppKeys.json, jsonEncode(json));
  }

  void editName() async {
    var sp = await SharedPreferences.getInstance();
    setState(() {
      String? getEditData = sp.getString(AppKeys.editData);
      var editedData = jsonDecode(getEditData ?? '');
      getTitleList[editIndex] = editedData['title'];
      getDescList[editIndex] = editedData['description'];
    });
  }

  void delName() async {
    var sp = await SharedPreferences.getInstance();
    final jsonString = sp.getString(AppKeys.json);
    final json = jsonDecode(jsonString!);
    List<dynamic> userDataList = json[sp.getString(AppKeys.currentUserKey)];
    setState(() {
      getTitleList.removeAt(delIndex);
      getDescList.removeAt(delIndex);
      getIdList.removeAt(delIndex);
      getStatusList.removeAt(delIndex);
      userDataList.removeAt(delIndex);
      json[sp.getString(AppKeys.currentUserKey)] = userDataList;
      sp.setString(AppKeys.json, jsonEncode(json));
    });
  }

  void getName() async {
    var sp = await SharedPreferences.getInstance();

    String? currentUserEmail =
        '"${sp.getString(AppKeys.currentUserKey) ?? ''}"';
    final jsonString = sp.getString(AppKeys.json);
    // print(jsonString);

    if (jsonString != null) {
      final json = jsonDecode(jsonString);
      // print(json);
      if (json.containsKey(sp.getString(AppKeys.currentUserKey))) {
        List<dynamic> userDataList = json[sp.getString(AppKeys.currentUserKey)];
        // print(userDataList);
        List<ToDoModel> dataList =
            userDataList.map((e) => ToDoModel.fromJson((e))).toList();
        getTitleList.clear();
        getDescList.clear();
        getIdList.clear();
        getStatusList.clear();
        for (int i = 0; i < userDataList.length; i++) {
          setState(() {
            final dataTitle = dataList[i].title;
            final dataDesc = dataList[i].description;
            final dataID = dataList[i].id;
            final dataStatus = dataList[i].status;
            getTitleList.add(dataTitle ?? '');
            getDescList.add(dataDesc ?? '');
            getIdList.add(dataID ?? 0);
            getStatusList.add(dataStatus ?? false);
          });
        }
      } else {
        json[currentUserEmail] = [];
        final userDataList = [];
        // print(userDataList);
        List<ToDoModel> dataList =
            userDataList.map((e) => ToDoModel.fromJson((e))).toList();
        getTitleList.clear();
        getDescList.clear();
        getIdList.clear();
        getStatusList.clear();
        for (int i = 0; i < userDataList.length; i++) {
          setState(() {
            final dataTitle = dataList[i].title;
            final dataDesc = dataList[i].description;
            final dataID = dataList[i].id;
            final dataStatus = dataList[i].status;
            getTitleList.add(dataTitle ?? '');
            getDescList.add(dataDesc ?? '');
            getIdList.add(dataID ?? 0);
            getStatusList.add(dataStatus ?? false);
          });
        }
      }
    } else {
      final json = {currentUserEmail: []};
      json[currentUserEmail] = [];
      sp.setString(AppKeys.json, json.toString());
    }
  }
//endregion
}
