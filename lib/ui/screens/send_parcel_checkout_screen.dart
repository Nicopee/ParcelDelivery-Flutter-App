import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:cargo_app/common/theme_helper.dart';
import 'package:cargo_app/ui/screens/agent_screen.dart';
import 'package:cargo_app/constants/constants.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SendParcelCheckoutScreen extends StatefulWidget {
  const SendParcelCheckoutScreen({Key? key}) : super(key: key);

  @override
  _SendParcelCheckoutScreenState createState() =>
      _SendParcelCheckoutScreenState();
}

class _SendParcelCheckoutScreenState extends State<SendParcelCheckoutScreen> {
  String tokens = "";
  String role = "";
  final _formKey = GlobalKey<FormState>();
  var packageData = Get.arguments;
  bool _isLoading = false;
  final TextEditingController userNameController = TextEditingController();

  void loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      tokens = prefs.getString("token")!;
      role = prefs.getString("role")!;
    });
  }

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Map<String, String> get headers => {
        "Authorization": "Bearer $tokens",
      };

  String dropdownvalue = 'pending';

  // List of items in our dropdown menu
  var items = [
    'transit',
    'pending',
    'rejected',
    'delivered',
  ];

  Future updateParcel() async {
    setState(() {
      _isLoading = true;
    });
    var pack = packageData[6].toString();
    var _url =
        Uri.parse(constants[0].url + 'package/' + pack + '/' + dropdownvalue);
    final response = await http.put(_url,
        body: {
          'amount_to_pay': userNameController.text,
        },
        headers: headers);
    final String responseData = response.body;
    if (response.statusCode == 200) {
      Get.to(() => const AgentHomeScreen(),
          fullscreenDialog: true,
          transition: Transition.zoom,
          duration: const Duration(microseconds: 500000));
      Get.snackbar('success', 'Parcel Updated');
      setState(() {
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
      Get.snackbar('Error  ', 'Error Occured');
    }

    return responseData;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 20,
          ),
          child: ListView(
            children: [
              Text(
                'Package Details',
                style: Theme.of(context).textTheme.headline1,
              ),
              const SizedBox(
                height: 21,
              ),
            ],
          ),
        ),
      ),
      bottomSheet: _buildBottomSheet(),
    );
  }

  Widget _buildBottomSheet() {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(24),
        height: MediaQuery.of(context).size.height * 0.5,
        width: double.infinity,
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(16),
            topLeft: Radius.circular(16),
          ),
          color: Color(0xFFf5f5f5),
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                role == "agent"
                    ? Column(
                        children: [
                          DropdownButton(
                            // Initial Value
                            value: dropdownvalue,

                            // Down Arrow Icon
                            icon: const Icon(Icons.keyboard_arrow_down),

                            // Array list of items
                            items: items.map((String items) {
                              return DropdownMenuItem(
                                value: items,
                                child: Text(items),
                              );
                            }).toList(),
                            // After selecting the desired option,it will
                            // change button value to selected value
                            onChanged: (String? newValue) {
                              setState(() {
                                dropdownvalue = newValue!;
                              });
                            },
                          ),
                          TextFormField(
                            controller: userNameController,
                            onSaved: (value) {
                              userNameController.text = value!;
                            },
                            validator: (text) {
                              if (text == null || text.isEmpty) {
                                return 'Amount is required';
                              }
                              return null;
                            },
                            decoration: ThemeHelper()
                                .textInputDecoration('Amount', 'Enter amount'),
                          ),
                        ],
                      )
                    : Text(''),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Summary',
                      style: Theme.of(context).textTheme.headline3,
                    ),
                  ],
                ),
                Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                  const Text('Package:'),
                  const SizedBox(
                    width: 30,
                  ),
                  Text(packageData[0])
                ]),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Recipient',
                      style: Theme.of(context).textTheme.headline4,
                    ),
                    Text(
                      '${packageData[5]}\n${packageData[1]}\n${packageData[2]}\n${packageData[3]}',
                      style: Theme.of(context).textTheme.headline5,
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Description',
                      style: Theme.of(context).textTheme.headline4,
                    ),
                    Text(
                      '${packageData[6]}',
                      style: Theme.of(context).textTheme.headline5,
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Delivery method',
                      style: Theme.of(context).textTheme.headline4,
                    ),
                    Text(
                      'Bus',
                      style: Theme.of(context).textTheme.headline5,
                    ),
                  ],
                ),
                role == "agent"
                    ? _isLoading
                        ? const CircularProgressIndicator()
                        : SizedBox(
                            height: 38,
                            width: double.infinity,
                            child: TextButton(
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  updateParcel();
                                }
                              },
                              child: Text(
                                'Update',
                                style: Theme.of(context).textTheme.bodyText1,
                              ),
                              style: Theme.of(context).textButtonTheme.style,
                            ),
                          )
                    : SizedBox(
                        height: 38,
                        width: double.infinity,
                        child: TextButton(
                          onPressed: () {},
                          child: Text(
                            'Amount to Pay: Ugx ${packageData[4]}',
                            style: Theme.of(context).textTheme.bodyText1,
                          ),
                          style: Theme.of(context).textButtonTheme.style,
                        ),
                      )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
