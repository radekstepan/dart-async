library async;

// See http://stackoverflow.com/a/13732459/105707
typedef dynamic OnCall(List);

class ArgsFunction extends Function {
    OnCall _onCall;
    ArgsFunction(this._onCall);
    noSuchMethod(Invocation invocation) {
        return _onCall(invocation.positionalArguments);
    }
}

each(array, fn, callback, [map=false]) {
    // Always have a callback.
    callback = (callback is Function) ? callback : () {};

    // List length.
    int length = array.length;
    // Mapped results?
    List results = (map) ? new List(length) : null;
    // To check if error has already happened.
    var error = null;
    
    // Call each, in parallel.
    for (var i = 0; i < length; i++) {
        fn(array[i], (err, [result]) {
            // Error, and already called.
            if (error != null) return;
            // New error?
            if (err != null) return callback(error = err);
            
            // Mapping the result?
            if (map) results[i] = result;
            
            // All done?
            if ((length -= 1) == 0) {
                (map) ? callback(null, results) : callback(null);
            }
        });
    }
}

eachSeries(array, fn, callback, [map=false]) {
    // Always have a callback.
    callback = (callback is Function) ? callback : () {};

    // List length.
    int length = array.length;
    // Mapped results?
    List results = (map) ? new List() : null;
    // Index.
    int i = 0;

    // Go through one item at a time.
    iterate() {
        fn(array[i++], (err, [result]) {
            // Error?
            if (err != null) return callback(err);

            // Mapping the result?
            if (map) results.add(result);
            
            // All done?
            if (i == length) {
                (map) ? callback(null, results) : callback(null);
            // Call again.
            } else {
                iterate();
            }
        });
    }

    iterate();
}

// Each in parallel, but mapping results.
map(array, fn, callback) {
    each(array, fn, callback, true);
}

// Each in series, but mapping results.
mapSeries(array, fn, callback) {
    eachSeries(array, fn, callback, true);
}

series(tasks, [callback]) {
    // Tasks length.
    int length = tasks.length;
    // Has a callback?
    bool hasCb = callback is Function;
    // Mapped results?
    List results = (hasCb) ? new List() : null;
    // Index.
    int i = 0;

    // Go through one task at a time.
    iterate() {
        tasks[i++]((err, [result]) {
            // Error?
            if (err != null) {
                // Callback provided?
                if (hasCb) callback(err);
                return;
            }

            // Mapping the result?
            if (hasCb) results.add(result);
            
            // All done?
            if (i == length) {
                if (hasCb) callback(null, results);
            // Call next task.
            } else {
                iterate();
            }
        });
    }

    iterate();

}

parallel(tasks, [callback]) {
    // Tasks length.
    int length = tasks.length;
    // Has a callback?
    bool hasCb = callback is Function;
    // Mapped results?
    List results = (hasCb) ? new List(length) : null;
    // To check if error has already happened.
    var error = null;
    
    // Call each, in parallel.
    for (var i = 0; i < length; i++) {
        tasks[i]((err, [result]) {
            // Error, and already called.
            if (error != null) return;
            // New error?
            if (err != null) {
                // Callback provided?
                if (hasCb) callback(err);
                return;
            }
            
            // Mapping the result?
            if (hasCb) {
                results[i] = result;
                // All done?
                if ((length -= 1) == 0) {
                    callback(null, results);
                }
            }
        });
    }
}

waterfall(tasks, [callback]) {
    // Number of tasks.
    int length = tasks.length;
    // Optional callback.
    bool hasCb = callback is Function;
    // Index.
    int i = 0;
    // Be able to extract positional args.
    ArgsFunction cb;

    handler(arguments) {
        // Non-null error.
        var err = arguments.first;

        // Error?
        if (err != null) {
            // Callback provided?
            if (hasCb) callback(err);
            return;
        }

        // All done?
        if (i == length) {
            // Call back with all arguments.
            if (hasCb) Function.apply(callback, arguments);
        
        // Call next task appending the callback.
        } else {
            // Get the rest of the args.
            List rest = arguments
            .getRange(1, arguments.length)
            .toList();
            // Add our callback again.
            rest.add(cb);
            Function.apply(tasks[i++], rest);
        }
    }

    cb = new ArgsFunction(handler);

    // Call the first task with just the callback.
    tasks[i++](cb);
}