library async_test;

import 'package:unittest/unittest.dart';
import 'package:dart-async/async.dart' as async;

import 'dart:math';
import 'dart:async';

var time = new Duration(milliseconds: 0);

main() {

    test('each', () {
        var entered = 0,
            array = [ 1, 3, 2 ];
        
        fn(number, cb) {
            entered += 1;
            var timer = new Timer(time, () {
                expect(entered, array.length);
                cb(null);
            });
        }

        async.each(array, expectAsync2(fn, count: array.length), (err) {
            expect(err, isNull);
            expect(entered, array.length);
        });
    });

    test('eachSeries', () {
        var entered = 0,
            array = [ 1, 2, 3];

        fn(number, cb) {
            entered += 1;
            var timer = new Timer(time, () {
                expect(entered, number);
                cb(null);
            });
        }

        async.eachSeries(array, expectAsync2(fn, count: array.length), (err) {
           expect(err, isNull);
           expect(entered, array.length);
        });
    });

    test('map', () {
        var entered = 0,
            array = [ 1, 3, 2 ];
        
        fn(number, cb) {
            entered += 1;
            var timer = new Timer(time, () {
                expect(entered, array.length);
                cb(null, number);
            });
        }

        async.map(array, expectAsync2(fn, count: array.length), (err, results) {
            expect(err, isNull);
            expect(entered, array.length);
            expect(results, [ 1, 3, 2 ]);
        });
    });

    test('mapSeries', () {
        var entered = 0,
            array = [ 1, 2, 3];

        fn(number, cb) {
            entered += 1;
            var timer = new Timer(time, () {
                expect(entered, number);
                cb(null, number);
            });
        }

        async.mapSeries(array, expectAsync2(fn, count: array.length), (err, results) {
           expect(err, isNull);
           expect(entered, array.length);
           expect(results, array);
        });
    });

    test('series', () {
        var entered = 0;

        one(cb) {
            entered += 1;
            var timer = new Timer(time, () {
                expect(entered, 1);
                cb(null, 1);
            });
        }

        two(cb) {
            entered += 1;
            var timer = new Timer(time, () {
                expect(entered, 2);
                cb(null, 2);
            });
        }

        async.series([
            expectAsync1(one),
            expectAsync1(two)
        ], (err, results) {
            expect(err, isNull);
            expect(results, [ 1, 2 ]);
        });
    });

    test('parallel', () {
        var entered = 0;

        one(cb) {
            entered += 1;
            var timer = new Timer(time, () {
                expect(entered, 2);
                cb(null, 1);
            });
        }

        two(cb) {
            entered += 1;
            var timer = new Timer(time, () {
                expect(entered, 2);
                cb(null, 2);
            });
        }

        async.parallel([
            expectAsync1(one),
            expectAsync1(two)
        ], (err, results) {
            expect(err, isNull);
            expect(results, [ 1, 2 ]);
        });
    });

    test('waterfall', () {
        one(cb) {
            var timer = new Timer(time, () {
                cb(null, 1);
            });
        }

        two(previous, cb) {
            var timer = new Timer(time, () {
                cb(null, previous + 1);
            });
        }

        async.waterfall([
            expectAsync1(one),
            expectAsync2(two)
        ], (err, results) {
            expect(err, isNull);
            expect(results, 2);
        });
    });

}