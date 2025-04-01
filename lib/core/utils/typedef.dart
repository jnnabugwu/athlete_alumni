import 'package:dartz/dartz.dart';
import 'package:athlete_alumni/core/errors/failures.dart';

typedef ResultFuture<T> = Future<Either<Failure, T>>;
