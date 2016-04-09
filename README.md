# Rails Issue 24028

This code seeks to reproduce [Rails Issue 24028](https://github.com/rails/rails/issues/24028).

Updated with the worst case possible scenario: Interlocked threads are siblings, with no common backtrace elements, with a busy loop to prevent detection of joins.

## Usage

1. Run: `ruby rails_issue_24028.rb`

## Result

```
Index
Started load A in main thread
Loaded A
Starting backtrace_munge to ensure Loader B does not share any common backtraces with Loader C
Waiting in main thread for A to load B
Started Loader C to load C
Sleeping in Loader C to ensure Loader B runs first
Started Loader B to load B
Loaded B
Sleeping in Loader B to ensure Loader C is definitely defined
Busy loop in Loader B to load C without any sort of join in the Loader B backtrace
Deadlock in Interlock...
Deadlock in Interlock...
Deadlock in Interlock...
Deadlock in Interlock...
Deadlock in Interlock...
Deadlock in Interlock...
...
```

Loading of B fails due to "only one thread loads" assumption.

## Expected Result

The ideal result would be to detect the deadlock, and somehow magically resolve it as so:

```
Index
Started load A in main thread
Loaded A
Starting backtrace_munge to ensure Loader B does not share any common backtraces with Loader C
Waiting in main thread for A to load B
Started Loader C to load C
Sleeping in Loader C to ensure Loader B runs first
Started Loader B to load B
Loaded B
Sleeping in Loader B to ensure Loader C is definitely defined
Busy loop in Loader B to load C without any sort of join in the Loader B backtrace
Loaded C
Done Loading
```

Alternatively, the system should notify user of the (potential) deadlock.

