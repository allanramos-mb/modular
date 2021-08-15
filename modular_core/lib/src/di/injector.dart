import 'bind.dart';
import 'bind_context.dart';
import 'resolvers.dart';

class Injector<T> {
  final _allBindContexts = <Type, BindContext>{};

  B call<B extends Object>([Bind<B>? bind]) => get<B>(bind);

  B get<B extends Object>([Bind<B>? bind]) {
    B? bind;

    for (var module in _allBindContexts.values) {
      bind = module.getBind<B>();
      if (bind != null) {
        break;
      }
    }

    if (bind != null) {
      return bind;
    } else {
      throw Exception('bind not found');
    }
  }

  void bindContext(BindContext module, {String tag = ''}) {
    final typeModule = module.runtimeType;
    if (!_allBindContexts.containsKey(typeModule)) {
      module.instantiateSingletonBinds(_getAllSingletons());
      _allBindContexts[typeModule] = module;
      printResolverFunc?.call("-- $typeModule INITIALIZED");
    } else {
      _allBindContexts[typeModule]?.tags.add(tag);
    }
  }

  bool dispose<B extends Object>() {
    final module = _allBindContexts.remove(_getType<B>());
    if (module != null) {
      module.dispose();
      return true;
    }
    return false;
  }

  void removeBindContext<T extends BindContext>() {
    _allBindContexts.remove(_getType<T>());
  }

  Type _getType<T>() => T;

  List<dynamic> _getAllSingletons() {
    final list = <dynamic>[];
    for (var module in _allBindContexts.values) {
      list.addAll(module.instanciatedSingletons);
    }
    return list;
  }
}
