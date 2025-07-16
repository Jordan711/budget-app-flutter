import 'package:budget_app_starting/components.dart';
import 'package:budget_app_starting/view_model.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ExpenseViewWeb extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModelProvider = ref.watch(viewModel);
    double deviceWidth = MediaQuery.of(context).size.width;
    double deviceHeight = MediaQuery.of(context).size.height;

    if (viewModelProvider.isLoading) {
      viewModelProvider.expenseStream();
      viewModelProvider.incomeStream();
      viewModelProvider.isLoading = false;
    }

    return SafeArea(
      child: Scaffold(
          drawer: DrawerExpense(),
          appBar: AppBar(
            iconTheme: IconThemeData(color: Colors.white, size: 30.0),
            backgroundColor: Colors.black,
            centerTitle: true,
            title: Poppins(text: "Dashboard", size: 20.0, color: Colors.white),
            actions: [
              IconButton(
                  onPressed: () async {
                    viewModelProvider.reset(context);
                  },
                  icon: Icon(Icons.refresh)),
            ],
          ),
          body: ListView(
            children: [
              SizedBox(height: 50.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset("assets/login_image.png",
                      width: deviceHeight / 1.6),
                  // Total Calculation
                  Container(
                    height: 300.0,
                    width: 280.0,
                    padding: EdgeInsets.all(15.0),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.all(Radius.circular(25.0)),
                    ),
                    child: TotalCalculation(17.0),
                  )
                ],
              ),
              SizedBox(height: 40.0),
              Divider(
                indent: deviceWidth / 4,
                endIndent: deviceWidth / 4,
                thickness: 3.0,
              ),
              SizedBox(height: 50.0),

              // Expenses + Incomes List
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    height: 320.0,
                    width: 260.0,
                    padding: EdgeInsets.all(15.0),
                    decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.all(Radius.circular(25.0))),
                    child: Column(
                      children: [
                        Center(
                          child: Poppins(
                              text: "Expenses",
                              size: 25.0,
                              color: Colors.white),
                        ),
                        Divider(
                          indent: 30.0,
                          endIndent: 30.0,
                          color: Colors.white,
                        ),
                        SizedBox(height: 15.0),
                        Container(
                          padding: EdgeInsets.all(10.0),
                          height: 210.0,
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.all(Radius.circular(25.0)),
                            border: Border.all(width: 1.0, color: Colors.white),
                          ),
                          child: ListView.builder(
                            itemBuilder: (BuildContext context, int index) {
                              return Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Poppins(
                                      text:
                                          viewModelProvider.expenses[index].name,
                                      size: 15.0,
                                      color: Colors.white),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: Poppins(
                                        text: "\$ " + viewModelProvider
                                            .expenses[index].amount,
                                        size: 15.0,
                                        color: Colors.white),
                                  ),
                                ],
                              );
                            },
                            itemCount: viewModelProvider.expenses.length,
                          ),
                        )
                      ],
                    ),
                  ),

                  Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AddExpense(),
                        SizedBox(height: 30.0),
                        AddIncome(),
                      ],
                    ),

                  // Income
                  Container(
                    height: 320.0,
                    width: 260.0,
                    padding: EdgeInsets.all(15.0),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.all(Radius.circular(25.0)),
                    ),
                    child: Column(
                      children: [
                        Center(
                          child: Poppins(
                              text: "Incomes", size: 25.0, color: Colors.white),
                        ),
                        Divider(
                            indent: 30.0, endIndent: 30.0, color: Colors.white),
                        SizedBox(
                          height: 15.0,
                        ),
                        Container(
                          padding: EdgeInsets.all(10.0),
                          height: 210.0,
                          decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(25.0)),
                              border:
                                  Border.all(width: 1.0, color: Colors.white)),
                          child: ListView.builder(
                            itemBuilder: (BuildContext context, int index) {
                              return Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Poppins(
                                      text:
                                          viewModelProvider.incomes[index].name,
                                      size: 15.0,
                                      color: Colors.white),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: Poppins(
                                        text: "\$ " + viewModelProvider
                                            .incomes[index].amount,
                                        size: 15.0,
                                        color: Colors.white),
                                  ),
                                ],
                              );
                            },
                            itemCount: viewModelProvider.incomes.length,
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              )
            ],
          )),
    );
  }
}
