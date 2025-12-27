import 'package:flutter/material.dart';
import 'package:r03foodui/UI/allclass.dart';
import 'package:r03foodui/UI/pagemain.dart';
import 'package:r03foodui/reptfunction/repttext.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/cart_services.dart';
import '../services/auth_services.dart';

import 'delivery.dart';

class CartsUi extends StatefulWidget {
  const CartsUi({super.key});

  @override
  State<CartsUi> createState() => _CartsUiState();
}

class _CartsUiState extends State<CartsUi> {
  int no_item = 1;
  foodhandle handeler = foodhandle();
  //get list from class
  List name = [];
  List price = [];
  List images = [];

  cartfunction() {
    name = showname();
    price = showprice();
    images = showimages();
    print(name);
    print(price);
    print(images);
  }

  double total = 0;
  num itemtotal = 0;

  void calculate() {
    for (int i = 0; i < price.length; i++) {
      itemtotal = itemtotal + price[i];
    }
    total = itemtotal + 1.2;
  }

  void initState() {
    super.initState();
    cartfunction();
    calculate();
  }

  @override
  Widget build(BuildContext context) {
    if (!AuthService.isLoggedIn) {
      return Scaffold(body: Center(child: Text("Login to view cart")));
    }

    return Padding(
        padding: EdgeInsets.all(15),
        child: Scaffold(
            backgroundColor: Colors.grey.shade200,
            body:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              SizedBox(height: 20),
              subtittle("Add item From The Homepage"),
              SizedBox(height: 35),
              Expanded(
                  flex: 4,
                  child: Column(children: [
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          darktittle("My Cart"),
                          GestureDetector(
                              onTap: () async {
                                try {
                                  await CartService.clearCart();
                                  Alert(
                                    context: context,
                                    type: AlertType.info,
                                    title: "Cleared Cart",
                                    desc: "Your Cart is Cleared",
                                    buttons: [
                                      DialogButton(
                                        child: Text(
                                          "Add item",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 20),
                                        ),
                                        onPressed: () => Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    pagemain())),
                                        color: Color.fromRGBO(0, 179, 134, 1.0),
                                      ),
                                      DialogButton(
                                        child: Text(
                                          "Ok",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 20),
                                        ),
                                        onPressed: () => Navigator.pop(context),
                                        color: Color.fromRGBO(0, 179, 134, 1.0),
                                      )
                                    ],
                                  ).show();
                                } catch (e) {
                                  Alert(
                                    context: context,
                                    type: AlertType.error,
                                    title: "Error",
                                    desc: "Could not clear cart.",
                                    buttons: [
                                      DialogButton(
                                        child: Text("Ok",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 20)),
                                        onPressed: () => Navigator.pop(context),
                                        color: Colors.red,
                                      ),
                                    ],
                                  ).show();
                                }
                              },
                              child: Icon(Icons.close))
                        ]),
                    Expanded(
                        child: StreamBuilder<QuerySnapshot>(
                      stream: CartService.getCart(),
                      builder:
                          (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }

                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          // update totals (only if changed to avoid rebuild loop)
                          if (itemtotal != 0 || total != 0) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (mounted) {
                                setState(() {
                                  itemtotal = 0;
                                  total = 0;
                                });
                              }
                            });
                          }
                          return Center(child: Text("Your cart is empty"));
                        }

                        double newItemTotal = 0;
                        for (var d in snapshot.data!.docs) {
                          final price = (d['price'] as num).toDouble();
                          final qty = (d['quantity'] as num).toInt();
                          newItemTotal += price * qty;
                        }

                        // update totals after frame (only if changed)
                        final newTotal = newItemTotal + 1.2;
                        if (itemtotal != newItemTotal || total != newTotal) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (mounted) {
                              setState(() {
                                itemtotal = newItemTotal;
                                total = newTotal;
                              });
                            }
                          });
                        }

                        return ListView(
                          children: snapshot.data!.docs.map((doc) {
                            final data = doc.data() as Map<String, dynamic>;
                            final productName = data['name'] ?? '';
                            final productPrice = data['price'] ?? 0;
                            final productImage = data['image'] ?? '';
                            final productQty = data['quantity'] ?? 1;

                            return Container(
                              padding: EdgeInsets.all(8),
                              margin: EdgeInsets.only(bottom: 3, top: 3),
                              height: 115,
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.7),
                                  borderRadius: BorderRadius.circular(10)),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    height: 110,
                                    width: 90,
                                    decoration: BoxDecoration(
                                        image: DecorationImage(
                                            image: AssetImage(
                                                "lib/assets/recommend/" +
                                                    productImage.toString() +
                                                    ".png"),
                                            fit: BoxFit.cover),
                                        borderRadius:
                                            BorderRadius.circular(16)),
                                  ),
                                  Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        mediumtext(productName.toString()),
                                        SizedBox(height: 15),
                                        Text("\$" + productPrice.toString(),
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500)),
                                      ]),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Row(
                                        children: [
                                          GestureDetector(
                                            onTap: () async {
                                              int newQty =
                                                  (productQty as int) - 1;
                                              if (newQty <= 0) {
                                                await CartService.removeItem(
                                                    doc.id);
                                              } else {
                                                await CartService
                                                    .updateItemQuantity(
                                                        doc.id, newQty);
                                              }
                                            },
                                            child: Container(
                                              height: 30,
                                              width: 30,
                                              decoration: BoxDecoration(
                                                  color: Colors.grey.shade200,
                                                  borderRadius:
                                                      BorderRadius.circular(5)),
                                              child: Icon(Icons.remove,
                                                  size: 20,
                                                  color: Colors.grey.shade700),
                                            ),
                                          ),
                                          SizedBox(width: 10),
                                          Text(productQty.toString(),
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w500)),
                                          SizedBox(width: 10),
                                          GestureDetector(
                                            onTap: () async {
                                              int newQty =
                                                  (productQty as int) + 1;
                                              await CartService
                                                  .updateItemQuantity(
                                                      doc.id, newQty);
                                            },
                                            child: Container(
                                              height: 30,
                                              width: 30,
                                              decoration: BoxDecoration(
                                                  color: Colors.grey.shade200,
                                                  borderRadius:
                                                      BorderRadius.circular(5)),
                                              child: Icon(Icons.add,
                                                  size: 20,
                                                  color: Colors.grey.shade700),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            );
                          }).toList(),
                        );
                      },
                    )),
                  ])),
              SizedBox(height: 10),
              Expanded(
                  flex: 5,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        subtittle("Have a promo code?"),
                        SizedBox(height: 10),
                        Container(
                            padding: EdgeInsets.all(8),
                            height: 50,
                            width: MediaQuery.of(context).size.width,
                            decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.7),
                                borderRadius: BorderRadius.circular(50)),
                            child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(children: [
                                    Text("DISCOUNT",
                                        style: TextStyle(
                                            color: Colors.red,
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold)),
                                    SizedBox(width: 5),
                                    Icon(Icons.verified_rounded,
                                        color: Colors.green)
                                  ]),
                                  GestureDetector(
                                      onTap: () {},
                                      child: Container(
                                          height: 50,
                                          width: 90,
                                          decoration: BoxDecoration(
                                              color: Colors.green,
                                              borderRadius:
                                                  BorderRadius.circular(40)),
                                          child: Center(
                                              child: Text("Apply",
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 18)))))
                                ])),
                        SizedBox(height: 10),
                        subtittle("Order Summary"),
                        SizedBox(height: 10),
                        Container(
                            padding: EdgeInsets.all(8),
                            height: 65,
                            width: MediaQuery.of(context).size.width,
                            child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        minortext("Items Total :"),
                                        minortext("\$" + itemtotal.toString())
                                      ]),
                                  Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        minortext("Delivery Fee :"),
                                        minortext("\$1.2")
                                      ])
                                ])),
                        Divider(color: Colors.black),
                        SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            subtittle("Total :"),
                            subtittle("\$" + total.toString())
                          ],
                        ),
                        SizedBox(height: 20),
                        GestureDetector(
                            onTap: (() {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => DeliveryUi()));
                            }),
                            child: Container(
                                height: 50,
                                width: MediaQuery.of(context).size.width,
                                decoration: BoxDecoration(
                                    color: Colors.green,
                                    borderRadius: BorderRadius.circular(40)),
                                child: Center(
                                    child: Text("Check out",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold)))))
                      ]))
            ])));
  }
}
