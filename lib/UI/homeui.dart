import 'package:flutter/material.dart';
import 'package:r03foodui/reptfunction/reptwidget.dart';
import '../reptfunction/repttext.dart';
import '../services/cart_services.dart';
import '../auth/auth_state.dart';

class HomeUi extends StatefulWidget {
  const HomeUi({super.key});

  @override
  State<HomeUi> createState() => _HomeUiState();
}

class _HomeUiState extends State<HomeUi> {
  int catcolor = 0;
  String searchText = '';

  List bakeriesname = ['Chocolate Pie', 'Glaze donout', 'Pizza', 'Bread'];
  List bakeriesprice = [12, 8, 24, 65];
  List bakeriesimages = ['ChocolatePie', 'gdnout', 'pizza', 'bread'];

  List drinkname = ['Coca Cola', 'Tuborg', 'strawberryJuice', 'Mineral Water'];
  List drinkprice = [45, 95, 53, 13];
  List drinkimages = ['cocacola', 'tuborg', 'strawberryJuice', 'mineralwater'];

  List fruitname = ['Watermelon', 'Banana', 'Orange', 'Lemon'];
  List fruitimages = ['watermelon', 'banana', 'orange', 'lemon'];
  List fruitprice = [35, 15, 25, 10];

  List saladname = [
    'Caesar Salad',
    'Caprese Salad',
    'Cobb Salad',
    'Niçoise Salad'
  ];
  List saladimages = [
    'caesarsalad',
    'capresesalad',
    'cobbsalad',
    'nicosalsalad'
  ];
  List saladprice = [40, 50, 60, 70];

  List catname = ['Bakeries', 'Drinks', 'Fruits', 'Salads'];
  List caticon = [
    Icons.cake_rounded,
    Icons.local_drink_rounded,
    Icons.fastfood_outlined,
    Icons.rice_bowl_rounded
  ];

  /// Returns widget based on category OR search
  Widget recmdfunc(int val) {
    if (searchText.isNotEmpty) {
      return searchResultWidget();
    }

    if (val == 0) {
      return recommendedfood(bakeriesname, bakeriesprice, bakeriesimages);
    } else if (val == 1) {
      return recommendedfood(drinkname, drinkprice, drinkimages);
    } else if (val == 2) {
      return recommendedfood(fruitname, fruitprice, fruitimages);
    } else {
      return recommendedfood(saladname, saladprice, saladimages);
    }
  }

  /// Search logic across all categories
  Widget searchResultWidget() {
    List names = [];
    List prices = [];
    List images = [];

    final allItems = [
      ...bakeriesname.asMap().entries.map((e) => {
            'name': e.value,
            'price': bakeriesprice[e.key],
            'image': bakeriesimages[e.key],
          }),
      ...drinkname.asMap().entries.map((e) => {
            'name': e.value,
            'price': drinkprice[e.key],
            'image': drinkimages[e.key],
          }),
      ...fruitname.asMap().entries.map((e) => {
            'name': e.value,
            'price': fruitprice[e.key],
            'image': fruitimages[e.key],
          }),
      ...saladname.asMap().entries.map((e) => {
            'name': e.value,
            'price': saladprice[e.key],
            'image': saladimages[e.key],
          }),
    ];

    final results = allItems.where((item) {
      return item['name']
          .toString()
          .toLowerCase()
          .contains(searchText.toLowerCase());
    }).toList();

    for (var item in results) {
      names.add(item['name']);
      prices.add(item['price']);
      images.add(item['image']);
    }

    return recommendedfood(names, prices, images);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: MediaQuery.of(context).size.height * 0.36,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('lib/assets/home.png'),
              fit: BoxFit.fill,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                tittletext('Hello,'),
                tittletext('Customers'),
                const SizedBox(height: 60),
                TextField(
                  onChanged: (value) {
                    setState(() {
                      searchText = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: '  Search for something tasty',
                    hintStyle: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                    suffixIcon: Container(
                      margin: const EdgeInsets.only(right: 10),
                      width: 37,
                      height: 37,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(37),
                      ),
                      child: const Icon(Icons.search, color: Colors.white),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height * 0.52,
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(10),
                    child: Text(
                      'Top Categories',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: TextButton(
                      onPressed: () {},
                      child: minortext("See all"),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 50,
                child: ListView.builder(
                  itemCount: 4,
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          catcolor = index;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        padding: const EdgeInsets.all(10),
                        width: 140,
                        decoration: BoxDecoration(
                          color: catcolor == index
                              ? Colors.orange
                              : Colors.white.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              caticon[index],
                              size: 40,
                              color: Colors.green,
                            ),
                            const SizedBox(width: 15),
                            Text(
                              catname[index],
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: subtittle('Recommended for you'),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: TextButton(
                      onPressed: () {},
                      child: minortext("See all"),
                    ),
                  ),
                ],
              ),
              Expanded(child: recmdfunc(catcolor)),
            ],
          ),
        ),
      ),
    );
  }
}
