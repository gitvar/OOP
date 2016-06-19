`a ||= b`
---------

 

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
if !a
  a = b
end
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

can be rewritten as:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
a ||= b
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

 

`a ||= b` is just shorthand for `a = a || b`; it works just like `+=`, `*=`, and
other similar assignment operators (which is the name I use for the entire group
of these constructs). So, yes, it's an "OR-equal".

However, though `a ||= b` is technically `a = a || b`, the more common
interpretation is `a = b unless a` -- assign `b` to `a` unless `a` already has a
non-false value (and, in particular, a non-nil value).

 
