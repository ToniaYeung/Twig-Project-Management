import 'package:flutter/material.dart';

typedef HasDataWidget<T> = Widget Function(
    BuildContext context, T snapshotData);

//A proxy for future builder, so it takes in the same parameters as future builder, but does the has data check as well.
// This means we do not need to repeat it every time
class LoadingFutureBuilder<T> extends StatelessWidget {
  final Future<T> future;
  final HasDataWidget<T> builder;
  final T initialData;

  const LoadingFutureBuilder({
    @required this.future,
    @required this.builder,
    this.initialData,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        initialData: initialData,
        future: future,
        builder: (BuildContext context, AsyncSnapshot<T> snapshot) {
          if (snapshot.hasData) {
            if (snapshot.hasError) {
              return const Text("An error has occurred");
            }

            return builder(context, snapshot.data);
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        });
  }
}
