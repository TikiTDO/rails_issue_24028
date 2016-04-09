# Rails Issue 24028

This code seeks to reproduce [Rails Issue 24028](https://github.com/rails/rails/issues/24028).

## Usage

1. Run: `ruby rails_issue_24028.rb`

## Result

```
Index
Started thread to load A
Loaded A
Started thread to load B
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
Started thread to load A
Loaded A
Started thread to load B
Loaded B
Done Loading
```

Alternatively, the system should notify user of the (potential) deadlock.

