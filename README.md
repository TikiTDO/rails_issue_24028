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

## Expected Result

<<<<<<< HEAD
```
Index
Started thread to load A
Loaded A
Started thread to load B
Loaded B
Done Loading
```

OR

Some sort of error notifying user of (potential) deadlock.

=======
No deadlock, or some sort of error from rails.
>>>>>>> a220656e2307517afd5b264c66f67abbe301a7d0
