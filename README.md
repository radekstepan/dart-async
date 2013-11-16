#dart-async

Basic asynchronous function in Dart ala [caolan/async](https://github.com/caolan/async). Postponed until we can do variable arguments properly.

```bash
$ pico Makefile # point to your own SDK
$ make install
$ make test
```

##Collections

1. `each(arr, iterator, callback)`: parallel each item in `arr`, `callback` only receives an error
1. `eachSeries(arr, iterator, callback)`: serial each
1. `map(arr, iterator, callback)`: parallel map `arr` to results in a callback
1. `mapSeries(arr, iterator, callback)`: serial map

##Control Flow

1. `series(tasks, [callback])`: run each task in an array of `tasks` functions in series, collecting results to `callback`
1. `parallel(tasks, [callback])`: run each task in an array of `tasks` functions in parallel, collecting results to `callback`
1. `waterfall(tasks, [callback])`: execute async `tasks` functions in series passing callbacks as params to the next function calling `callback` with results