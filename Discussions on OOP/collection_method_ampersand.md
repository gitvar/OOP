### The a ||= b Assignment Operator

a ||= b is just shorthand for a = a || b; it works just like +=, *=, and other similar assignment operators (which is the name I use for the entire group of these constructs). So, yes, it's an "OR-equal".

However, though a ||= b is technically a = a || b, the more common interpretation is a = b unless a -- assign b to a unless a already has a non-false value (and, in particular, a non-nil value).

### something.method(&:other_method)

You do kind of need to understand Procs to fully grasp WHY something like array.map(&:method_name) works, but you can use it even if you don't know why it does. The simplest way to think of it is "syntactic sugar"; a convenient shortcut in the ruby syntax. In particular:

**something.method(&:other_method)**

**is "sugar" for**

**something.method { |value| value.other_method }**

It doesn't work with all methods, but many of the methods in Array, Hash, and Enumerable do recognize this syntax. **The main thing is that "other_method" must take no arguments, and it must be a valid method for value. It's particularly useful with map, inject, select, and reject.**

You'll see it often, so it's worth recognizing what it does, even if you never use it yourself.
