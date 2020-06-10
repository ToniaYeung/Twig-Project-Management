import 'package:flutter/material.dart';

typedef HasDataWidget<T> = Widget Function(
    BuildContext context, T snapshotData);

//A proxy for stream builder, so it takes in the same parameters as stream builder, but does the has data check as well.
// This means we do not need to repeat it every time
class LoadingStreamBuilder<T> extends StatelessWidget {
  final Stream<T> stream;
  final HasDataWidget<T> builder;
  final T initialData;

  const LoadingStreamBuilder({
    Key key,
    @required this.stream,
    @required this.builder,
    this.initialData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        initialData: initialData,
        stream: stream,
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
