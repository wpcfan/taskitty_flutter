import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nested/nested.dart';

extension BlocExtensions on Widget {
  Widget withBloc<T extends BlocBase<Object?>>(T bloc) {
    return BlocProvider<T>(
      create: (context) => bloc,
      child: this,
    );
  }

  Widget withBlocListener<T extends BlocBase<Object?>>(
      T bloc, BlocWidgetListener<Object?> listener) {
    return BlocProvider<T>(
      create: (context) => bloc,
      child: BlocListener<T, Object?>(
        bloc: bloc,
        listener: listener,
        child: this,
      ),
    );
  }

  Widget withMultiBlocs(List<BlocBase<Object?>> blocs) {
    return MultiBlocProvider(
      providers:
          blocs.map((bloc) => BlocProvider(create: (context) => bloc)).toList(),
      child: this,
    );
  }

  Widget withMultiBlocListeners(
      List<BlocBase<Object?>> blocs, List<SingleChildWidget> listeners) {
    return MultiBlocProvider(
      providers:
          blocs.map((bloc) => BlocProvider(create: (context) => bloc)).toList(),
      child: MultiBlocListener(
        listeners: listeners,
        child: this,
      ),
    );
  }
}
