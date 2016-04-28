# Rails Issue 24028

This code seeks to reproduce [Rails Issue 24028](https://github.com/rails/rails/issues/24028).

Updated with the worst case possible scenario: Interlocked threads are siblings, with no common backtrace elements, with a busy loop to prevent detection of joins.

## Usage

1. Run: `ruby rails_issue_24028.rb`

## Description

1. The main rails thread autoloads class `AutoloadA`
2. `AutoloadA` creates new threads, `LoaderB` and `LoaderC` to autoload `AutoloadB` and `AutoloadC` respectively
  1. `LoaderB` is initialized through a `Kernel.load` to ensure no shared backtraces with `LoaderC`
3. `LoaderC` sleeps before autoloading to ensure `LoaderB` runs first
4. `LoaderB` autoloads `AutoloadB`, which then waits of a simulated CV from `AutoloadC`
5. `AutoloadC` never runs, because `AutoloadB` holds exclusive lock, and will not release it until AutoloadC is loaded

`LoaderB` backtrace ends up as follows:

```
/rails_issue_24028/autoload_b.rb:9:in `<class:AutoloadB>'
/rails_issue_24028/autoload_b.rb:1:in `<top (required)>'
/rails/activesupport/lib/active_support/dependencies.rb:477:in `load'
/rails/activesupport/lib/active_support/dependencies.rb:477:in `block in load_file'
/rails/activesupport/lib/active_support/dependencies.rb:662:in `new_constants_in'
/rails/activesupport/lib/active_support/dependencies.rb:476:in `load_file'
/rails/activesupport/lib/active_support/dependencies.rb:375:in `block in require_or_load'
/rails/activesupport/lib/active_support/dependencies.rb:37:in `block in load_interlock'
/rails/activesupport/lib/active_support/dependencies/interlock.rb:44:in `block in loading'
/rails/activesupport/lib/active_support/concurrency/share_lock.rb:117:in `exclusive'
/rails/activesupport/lib/active_support/dependencies/interlock.rb:42:in `loading'
/rails/activesupport/lib/active_support/dependencies.rb:37:in `load_interlock'
/rails/activesupport/lib/active_support/dependencies.rb:358:in `require_or_load'
/rails/activesupport/lib/active_support/dependencies.rb:511:in `load_missing_constant'
/rails/activesupport/lib/active_support/dependencies.rb:203:in `const_missing'
backtrace_munge.rb:4:in `block in <top (required)>'
```

`LoaderC` backtrace ends up as follows:

```
/ruby-2.3.0/lib/ruby/2.3.0/monitor.rb:111:in `sleep'
/ruby-2.3.0/lib/ruby/2.3.0/monitor.rb:111:in `wait'
/ruby-2.3.0/lib/ruby/2.3.0/monitor.rb:111:in `wait'
/ruby-2.3.0/lib/ruby/2.3.0/monitor.rb:123:in `wait_while'
/rails/activesupport/lib/active_support/concurrency/share_lock.rb:49:in `block (2 levels) in start_exclusive'
/rails/activesupport/lib/active_support/concurrency/share_lock.rb:153:in `yield_shares'
/rails/activesupport/lib/active_support/concurrency/share_lock.rb:48:in `block in start_exclusive'
/ruby-2.3.0/lib/ruby/2.3.0/monitor.rb:214:in `mon_synchronize'
/rails/activesupport/lib/active_support/concurrency/share_lock.rb:43:in `start_exclusive'
/rails/activesupport/lib/active_support/concurrency/share_lock.rb:115:in `exclusive'
/rails/activesupport/lib/active_support/dependencies/interlock.rb:42:in `loading'
/rails/activesupport/lib/active_support/dependencies.rb:37:in `load_interlock'
/rails/activesupport/lib/active_support/dependencies.rb:358:in `require_or_load'
/rails/activesupport/lib/active_support/dependencies.rb:511:in `load_missing_constant'
/rails/activesupport/lib/active_support/dependencies.rb:203:in `const_missing'
/rails/activesupport/lib/active_support/dependencies.rb:543:in `load_missing_constant'
/rails/activesupport/lib/active_support/dependencies.rb:203:in `const_missing'
/rails_issue_24028/autoload_a.rb:13:in `block in <class:AutoloadA>'
```

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

