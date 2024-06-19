import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class SkeletonLoader extends StatelessWidget {
  const SkeletonLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: 5, // Quantidade de itens esqueléticos a serem exibidos
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    height: 60,
                    color: Colors.grey[300],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SkeletonItem extends StatelessWidget {
  const SkeletonItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(
                        height: 24,
                        width: 150,
                        color: Colors.grey[300],
                      ),
                    ),
                    Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(
                        height: 30,
                        width: 30,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(
                        height: 18,
                        width: 100,
                        color: Colors.grey[300],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(
                        height: 18,
                        width: 50,
                        color: Colors.grey[300],
                      ),
                    ),
                  ],
                ),
                const Divider(
                  color: Colors.grey,
                  thickness: 1,
                ),
                const SizedBox(height: 5),
                LayoutBuilder(
                  builder: (context, constraints) {
                    return SizedBox(
                      height: constraints.maxHeight >
                              MediaQuery.of(context).size.height * 0.5
                          ? MediaQuery.of(context).size.height * 0.5
                          : constraints.maxHeight,
                      child: ListView.builder(
                        itemCount:
                            4, // Quantidade de itens esqueléticos a serem exibidos
                        itemBuilder: (context, index) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Shimmer.fromColors(
                            baseColor: Colors.grey[300]!,
                            highlightColor: Colors.grey[100]!,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Column(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        20, 5, 20, 0),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        SizedBox(
                                          height: 18,
                                          width: 100,
                                        ),
                                        SizedBox(
                                          height: 35,
                                          width: 35,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        20, 5, 20, 20),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          height: 40,
                                          width: 40,
                                        ),
                                        SizedBox(width: 10),
                                        SizedBox(
                                          height: 40,
                                          width: 40,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
